require 'vagrant'

require 'pe_build/archive'
require 'pe_build/util/config'

require 'log4r'
require 'fileutils'

module PEBuild
  module Provisioner
    class PEBootstrap < Vagrant.plugin('2', :provisioner)

      require 'pe_build/provisioner/pe_bootstrap/answers_file'
      require 'pe_build/provisioner/pe_bootstrap/post_install'

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
        prepare_answers_file
        load_archive
        fetch_installer

        [:base, @config.role].each { |rolename| process_step rolename, :pre }

        @machine.guest.capability('run_install', @config, @archive)

        run_postinstall_tasks

        [:base, @config.role].each { |rolename| process_step rolename, :post }
      end

      private

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
        if @config.suffix == :detect and @config.filename.nil?
          filename = @machine.guest.capability('detect_installer', @config.version)
        else
          filename = @config.filename
        end

        @archive = PEBuild::Archive.new(filename, @machine.env)
        @archive.version = @config.version
      end

      # @todo panic if @config.download_root is undefined
      def fetch_installer
        uri = @config.download_root
        @archive.fetch(@config.download_root)
        @archive.unpack_to(@work_dir)
      end

      require 'pe_build/on_machine'
      include PEBuild::OnMachine

      def process_step(role, stepname)

        if role != :base && config.step[stepname]
          if File.file? config.step[stepname]
            script_list = [*config.step[stepname]]
          else
            script_list = []
            @machine.ui.warn "Cannot find defined step for #{role}/#{stepname.to_s} at \'#{config.step[stepname]}\'"
          end
        else
          # We do not have a user defined step for this role or we're processing the :base step
          script_dir  = File.join(PEBuild.source_root, 'bootstrap', role.to_s, stepname.to_s)
          script_list = Dir.glob("#{script_dir}/*")
        end

        if script_list.empty?
          @logger.info "No steps for #{role}/#{stepname}"
        end

        script_list.each do |template_path|
          # A message to show which step's action is running
          @machine.ui.info "Running action for #{role}/#{stepname}"
          template = File.read(template_path)
          contents = ERB.new(template).result(binding)

          on_machine(@machine, contents)
        end
      end

      def run_postinstall_tasks
        postinstall = PostInstall.new(@machine, @config, @work_dir)
        postinstall.run
      end
    end
  end
end
