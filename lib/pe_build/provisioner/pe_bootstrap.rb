require 'vagrant'

require 'pe_build/archive'
require 'pe_build/util/config'
require 'pe_build/util/versioned_path'

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
          machine.guest.capability('run_install', @config, @archive)
        end

        run_postinstall_tasks
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

        merged = PEBuild::Util::Config.local_merge(provision, global)

        @config = merged
      end

      def prepare_answers_file
        af = AnswersFile.new(@machine, @config, @work_dir)
        af.generate
      end

      def load_archive
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
        uri = @config.download_root
        @archive.fetch(@config.download_root)
        @archive.unpack_to(@work_dir)
      end

      def run_postinstall_tasks
        postinstall = PostInstall.new(@machine, @config, @work_dir)
        postinstall.run
      end
    end
  end
end
