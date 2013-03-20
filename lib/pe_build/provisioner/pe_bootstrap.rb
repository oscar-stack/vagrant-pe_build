require 'vagrant'

require 'log4r'
require 'fileutils'
require 'erb'

require 'pe_build/action'

module PEBuild; module Provisioner

class PEBootstrapError < Vagrant::Errors::VagrantError
  #error_namespace('vagrant.provisioners.pe_bootstrap')
end

class PEBootstrap < Vagrant.plugin('2', :provisioner)

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

    @logger = Log4R::Logger.new('vagrant::provisioners::pe_bootstrap')

    @work_dir    = File.join(@machine.env.root_path, '.pe_build')
    @answer_dir  = File.join(work_dir, 'answers')
    @answer_file = (@config.answers || File.join(answer_dir, "#{@machine.name}.txt"))
  end

  # Instantiate all working directory content and stage the PE installer.
  def configure
    unless File.directory? work_dir
      FileUtils.mkdir_p work_dir
    end

    unless File.directory answers_dir
      FileUtils.mkdir_p answers_dir
    end

    @machine.env[:action_runner].run(
      PEBuild::Action.stage_pe,
      :unpack_directory => @work_dir
    )
  end

  def provision!
    # determine if bootstrapping is necessary

    prepare_answers_file
    configure_installer

    [:pre, :provision, :post].each do |stepname|
      [:base, config.role].each do |rolename|
        process_step rolename, stepname
      end
    end
  end

  private

  # I HATE THIS.
  def load_variables
    if @env[:box_name]
      @root     = @env[:vm].pe_build.download_root
      @version  = @env[:vm].pe_build.version
      @filename = @env[:vm].pe_build.version
      @suffix   = @env[:vm].pe_build.suffix
    end

    @root     ||= @env[:global_config].pe_build.download_root
    @version  ||= @env[:global_config].pe_build.version
    @filename ||= @env[:global_config].pe_build.filename
    @suffix   ||= @env[:global_config].pe_build.suffix
  end

  def prepare_answers_file
    @env[:ui].info "Creating answers file, node:#{@env[:vm].name}, role: #{config.role}"
    FileUtils.mkdir_p @answers_dir unless File.directory? @answers_dir
    dest = "#{@answers_dir}/#{@env[:vm].name}.txt"

    # answers dir is enforced
    user_answers = File.join(@env[:root_path],"answers/#{config.answers}")
    if File.exists?(user_answers)
      template = File.read(user_answers)
    else
      @env[:ui].info "Using default answers, no answers file available at #{user_answers}"
      template = File.read("#{PEBuild.source_root}/templates/answers/#{config.role}.txt.erb")
    end

    contents = ERB.new(template).result(binding)

    @env[:ui].info "Writing answers file to #{dest}"
    File.open(dest, "w") do |file|
      file.write contents
    end
  end

  def process_step(role, stepname)

    if role != :base && config.step[stepname]
      if File.file? config.step[stepname]
        script_list = [*config.step[stepname]]
      else
        script_list = []
        @env[:ui].warn "Cannot find defined step for #{role}/#{stepname.to_s} at \'#{config.step[stepname]}\'"
      end
    else
      # We do not have a user defined step for this role or we're processing the :base step
      script_dir  = File.join(PEBuild.source_root, 'bootstrap', role.to_s, stepname.to_s)
      script_list = Dir.glob("#{script_dir}/*")
    end

    if script_list.empty?
      @env[:ui].info "No steps for #{role}/#{stepname}", :color => :cyan
    end

    script_list.each do |template_path|
      # A message to show which step's action is running
      @env[:ui].info "Running action for #{role}/#{stepname}"
      template = File.read(template_path)
      contents = ERB.new(template).result(binding)

      on_remote contents
    end
  end

  # Determine the proper invocation of the PE installer
  def configure_installer
    vm_base_dir = "/vagrant/.pe_build"
    installer   = "#{vm_base_dir}/puppet-enterprise-#{@version}-#{@suffix}/puppet-enterprise-installer"
    answers     = "#{vm_base_dir}/answers/#{@env[:vm].name}.txt"
    log_file    = "/root/puppet-enterprise-installer-#{Time.now.strftime('%s')}.log"

    @installer_cmd = "#{installer} -a #{answers} -l #{log_file}"
  end

  def on_remote(cmd)
    env[:vm].channel.sudo(cmd) do |type, data|
      color = (type == :stdout) ? :green : :red
      @env[:ui].info(data.chomp, :color => color, :prefix => false)
    end
  end
end

end; end
