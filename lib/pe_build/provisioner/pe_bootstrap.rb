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

    @logger = Log4r::Logger.new('vagrant::provisioners::pe_bootstrap')

    @work_dir    = File.join(@machine.env.root_path, '.pe_build')
    @answer_dir  = File.join(work_dir, 'answers')
    @answer_file = @config.answer_file
  end

  # Instantiate all working directory content and stage the PE installer.
  def configure(some_mysterious_and_undocumented_variable)
    unless File.directory? work_dir
      FileUtils.mkdir_p work_dir
    end

    unless File.directory? answer_dir
      FileUtils.mkdir_p answer_dir
    end

    @machine.env.action_runner.run(
      PEBuild::Action.stage_pe,
      :unpack_directory => @work_dir
    )
  end

  def provision
    # determine if bootstrapping is necessary

    prepare_answers_file
    configure_installer

    #perform_installation
    #relocate_installation if @config.role == :master

    [:pre, :provision, :post].each do |stepname|
      [:base, config.role].each do |rolename|
        process_step rolename, stepname
      end
    end
  end

  private

  # @return [String] The final path to the installer answers file
  def installer_answer_file
    File.join(@answer_dir, "#{@machine.name}.txt")
  end

  def prepare_answers_file
    @machine.env.ui.info "Creating answers file, node:#{@machine.name}, role: #{config.role}"

    if @answer_file
      template_path = @answer_file
    else
      template_path = File.join(PEBuild.template_dir, 'answers', "#{config.role}.txt.erb")
    end

    template = File.read(template_path)

    str = ERB.new(template).result(binding)


    @machine.env.ui.info "Writing answers file to #{installer_answer_file}"
    File.open(installer_answer_file, "w") do |file|
      file.write(str)
    end
  end

  def process_step(role, stepname)

    if role != :base && config.step[stepname]
      if File.file? config.step[stepname]
        script_list = [*config.step[stepname]]
      else
        script_list = []
        @machine.env.ui.warn "Cannot find defined step for #{role}/#{stepname.to_s} at \'#{config.step[stepname]}\'"
      end
    else
      # We do not have a user defined step for this role or we're processing the :base step
      script_dir  = File.join(PEBuild.source_root, 'bootstrap', role.to_s, stepname.to_s)
      script_list = Dir.glob("#{script_dir}/*")
    end

    if script_list.empty?
      @machine.env.ui.info "No steps for #{role}/#{stepname}", :color => :cyan
    end

    script_list.each do |template_path|
      # A message to show which step's action is running
      @machine.env.ui.info "Running action for #{role}/#{stepname}"
      template = File.read(template_path)
      contents = ERB.new(template).result(binding)

      on_remote contents
    end
  end

  # Determine the proper invocation of the PE installer
  def configure_installer
    root = "/vagrant/.pe_build"

    installer_dir = "puppet-enterprise-#{@config.version}-#{@config.suffix}"
    installer     = "puppet-enterprise-installer"

    answers     = "#{root}/answers/#{@machine.name}.txt"
    log_file    = "/root/puppet-enterprise-installer-#{Time.now.strftime('%s')}.log"

    cmd = File.join(root, installer_dir, installer)

    @installer_cmd = "#{cmd} -a #{answers} -l #{log_file}"
  end

  def on_remote(cmd)
    @machine.communicate.sudo(cmd) do |type, data|
      color = (type == :stdout) ? :green : :red
      @machine.env.ui.info(data.chomp, :color => color, :prefix => false)
    end
  end
end

end; end
