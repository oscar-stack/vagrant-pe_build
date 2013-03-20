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

    @logger.info "Creating answers file, node:#{@machine.name}, role: #{config.role}"
    prepare_answers_file

    [:base, config.role].each do |rolename|
      process_step rolename, :pre
    end

    perform_installation
    #relocate_installation if @config.role == :master

    [:base, config.role].each do |rolename|
      process_step rolename, :post
    end
  end

  private

  def generate_answers
    default_template_path = File.join(PEBuild.template_dir, 'answers', "#{config.role}.txt.erb")
    if @answer_file
      template_path = @answer_file
    else
      template_path = default_template_path
    end
    template = File.read(template_path)
    str = ERB.new(template).result(binding)
  end

  def prepare_answers_file
    str = generate_answers

    dest_file = File.join(@answer_dir, "#{@machine.name}.txt")

    @machine.env.ui.info "Writing answers file to #{dest_file}"
    File.open(dest_file, "w") do |file|
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
      @logger.info "No steps for #{role}/#{stepname}", :color => :cyan
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
  def installer_cmd
    root = "/vagrant/.pe_build"

    installer_dir = "puppet-enterprise-#{@config.version}-#{@config.suffix}"
    installer     = "puppet-enterprise-installer"

    answers     = "#{root}/answers/#{@machine.name}.txt"
    log_file    = "/root/puppet-enterprise-installer-#{Time.now.strftime('%s')}.log"

    cmd = File.join(root, installer_dir, installer)

    @installer_cmd = "#{cmd} -a #{answers} -l #{log_file}"
  end

  def perform_installation
    if @machine.communicate.test('test -f /opt/puppet/pe_version')
      @machine.env.ui.info "Puppet Enterprise is already installed, skipping installation.",
        :name  => @machine.name,
        :color => :red
    else
      on_remote installer_cmd
      @machine.env.ui.info "Scheduling puppet run to prime pe_mcollective"
      on_remote "echo '/opt/puppet/bin/puppet agent -t' | at next minute"
    end
  end

  def on_remote(cmd, verbose = false)
    @machine.communicate.sudo(cmd) do |type, data|
      if type == :stdout
        if verbose
          $stdout.print "\r"
          @machine.env.ui.info(data.chomp, :color => :green, :prefix => true)
        else
          $stdout.print '.'
          $stdout.flush
        end
      else
        $stdout.print "\r"
        @machine.env.ui.info(data.chomp, :color => :red, :prefix => true)
      end
    end
  end
end

end; end
