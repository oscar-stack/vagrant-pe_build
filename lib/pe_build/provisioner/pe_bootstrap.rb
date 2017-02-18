require 'vagrant'

require 'pe_build/archive'
require 'pe_build/util/config'
require 'pe_build/util/versioned_path'
require 'pe_build/util/version_string'

require 'log4r'
require 'fileutils'

require 'uri'

module PEBuild
  module Provisioner
    class PEBootstrap < Vagrant.plugin('2', :provisioner)

      require 'pe_build/provisioner/pe_bootstrap/answers_file'
      require 'pe_build/provisioner/pe_bootstrap/post_install'

      class UnsetVersionError < Vagrant::Errors::VagrantError
        error_key(:unset_version, 'pebuild.provisioner.pe_bootstrap.errors')
      end

      class AgentRoleRemovedError < Vagrant::Errors::VagrantError
        error_key(:agent_role_removed, 'pebuild.provisioner.pe_bootstrap.errors')
      end

      # @!attribute [r] work_dir
      #   @return [String] The path to the machine pe_build working directory

      attr_reader :work_dir

      # @!attribute [r] answer_dir
      #   @return [String] The path to the default answer file template dir
      attr_reader :answer_dir

      # @!attribute [r] answer_file
      #   @return [String] The path to the answer file for this machine.
      attr_reader :answer_file

      def initialize(machine, config)
        super

        @logger = Log4r::Logger.new('vagrant::provisioners::pe_bootstrap')

        @work_dir   = File.join(@machine.env.root_path.join, PEBuild::WORK_DIR)
        @answer_dir = File.join(work_dir, 'answers')
      end

      # Instantiate all working directory content and stage the PE installer.
      #
      # @param root_config [Object] ???
      # @return [void]
      def configure(root_config)
        late_config_merge(root_config)

        unless File.directory? work_dir
          FileUtils.mkdir_p work_dir
        end
      end

      def provision
        load_archive

        if pe_installed?
          machine.ui.warn I18n.t('pebuild.provisioner.pe_bootstrap.already_installed'),
                          :name  => machine.name
        else
          prepare_answers_file
          fetch_installer
          run_install
          run_postinstall_tasks
        end
      end

      private

      def pe_installed?
        case machine.guest.capability_host_chain.first.first
        when :windows
          gt_win2k3_path = '${Env:ALLUSERSPROFILE}\\PuppetLabs'
          le_win2k3_path = '${Env:ALLUSERSPROFILE}\\Application Data\\PuppetLabs'
          testpath = "(Test-Path \"#{gt_win2k3_path}\") -or (Test-Path \"#{le_win2k3_path}\")"

          machine.communicate.test("If (#{testpath}) { Exit 0 } Else { Exit 1 }")
        else
          machine.communicate.test('test -f /opt/puppet/pe_version || test -f /opt/puppetlabs/server/pe_version')
        end
      end

      def late_config_merge(root_config)
        provision = @config
        global    = root_config.pe_build

        # We don't necessarily know if the configs have been merged. If a config
        # is being used for default values and was never directly touched then it
        # may have bad values, so we re-finalize everything. This may not be
        # generally safe but inside of this plugin it should be ok.
        global.finalize!
        provision.finalize!

        @config = PEBuild::Util::Config.local_merge(provision, global)

        # If a version file is set, use its contents to specify the PE version.
        unless @config.version_file.nil?
          if URI.parse(@config.version_file).scheme.nil?
            # Non-URI paths are joined to the download root.
            path = "#{@config.download_root}/#{@config.version_file}"
          else
            path = @config.version_file
          end
          path = PEBuild::Util::VersionedPath.versioned_path(path, @config.version, @config.series)
          @config.version = PEBuild::Transfer.read(URI.parse(path))
        end

        raise UnsetVersionError if @config.version.nil?

        if (PEBuild::Util::VersionString.compare(@config.version, '2016.2.0') >= 0)
          @config.role ||= :master
        else
          @config.role ||= :agent
        end

        if (@config.role == :agent) &&
          (PEBuild::Util::VersionString.compare(@config.version, '2016.2.0') >= 0)
          raise AgentRoleRemovedError, machine_name: @machine.name
        elsif (@config.role == :agent) &&
          (PEBuild::Util::VersionString.compare(@config.version, '2015.2.0') >= 0)
          @machine.ui.warn I18n.t(
            'pebuild.provisioner.pe_bootstrap.warnings.agent_role_deprecated',
            machine_name: @machine.name)
        end
      end

      def prepare_answers_file
        @answer_template = AnswersFile.new(@machine, @config, @work_dir)
        @answer_template.generate

        unless @config.shared_installer
          @machine.communicate.upload(File.join(@answer_dir, "#{@machine.name}.txt"), "#{machine.name}.txt")
        end
      end

      def load_archive
        if @config.suffix == :detect and @config.filename.nil?
          filename = @machine.guest.capability('detect_installer', @config.version)
        else
          filename = @config.filename
        end

        @archive = PEBuild::Archive.new(filename, @machine.env)
        @archive.series = @config.series
        @archive.version = @config.version
      end

      # @todo panic if @config.download_root is undefined
      def fetch_installer
        if @config.shared_installer
          uri = @config.download_root
          @archive.fetch(@config.download_root)
          @archive.unpack_to(@work_dir)
        else
          @machine.guest.capability(:stage_installer, @archive.source_uri(@config.download_root), '.')
        end
      end

      def run_install
        case machine.guest.capability_host_chain.first.first
        when :windows
          if @config.shared_installer
            drive = machine.communicate.shell.cmd('ECHO %SYSTEMDRIVE%')[:data][0][:stdout].chomp
            installer_dir = File.join(drive, 'vagrant', PEBuild::WORK_DIR)

            installer_path = File.join(installer_dir, @archive.filename)
          else
            installer_path = @archive.filename
          end

          # Windows installations don't use answer files.
          answers = {
            'PUPPET_MASTER_SERVER'  => @config.master,
            'PUPPET_AGENT_CERTNAME' => machine.name,
          }

          # These options are only used on POSIX nodes.
          use_pem = false
          update_gpg = false
        else
          if @config.shared_installer
            root = File.join('/vagrant', PEBuild::WORK_DIR)
            installer_path = File.join(root, @archive.installer_dir)
            answers = File.join(root, 'answers', "#{machine.name}.txt")
          else
            installer_path = @archive.installer_dir
            answers = "#{machine.name}.txt"
          end

          # Run a PEM install if the PE version is 2016.2.0 or newer.
          use_pem = (PEBuild::Util::VersionString.compare(@config.version, '2016.2.0') >= 0)

          # PE versions prior to 2016.4.0 were signed with a GPG key that
          # expired on January 2nd, 2017.
          update_gpg = (PEBuild::Util::VersionString.compare(@config.version, '2016.4.0') < 0)

          if update_gpg
            machine.ui.info(
              I18n.t('pebuild.provisioner.pe_bootstrap.updating_gpg_key',
                :version => @config.version))
            machine.communicate.upload(
              File.join(
                PEBuild.source_root,
                'data', 'vagrant-pe_build', 'files', 'GPG-KEY-puppetlabs'),
              "#{installer_path}/gpg/GPG-KEY-puppetlabs")
          end
        end

        machine.guest.capability('run_install', installer_path, answers,
          use_pem: use_pem, update_gpg: update_gpg)
      end

      def run_postinstall_tasks
        postinstall = PostInstall.new(@machine, @config, @work_dir)
        postinstall.run
      end
    end
  end
end
