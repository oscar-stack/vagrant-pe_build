require 'pe_build/release'

require 'erb'

# A sub-provisioner which generates answer file content.
#
# This is an internal provisioner which is invoked by
# `PEBuild::Provisioner::PEBootstrap`.
#
# @api private
class PEBuild::Provisioner::PEBootstrap::AnswersFile

  attr_reader :template

  # @param machine [Vagrant::Machine]
  # @param config [Object < Vagrant.plugin('2', :config)]
  # @param work_dir [String]
  def initialize(machine, config, work_dir)
    @machine, @config = machine, config
    @work_dir = Pathname.new(work_dir)

    @logger = Log4r::Logger.new('vagrant::provisioner::pe_bootstrap::answers_file')

    @answer_dir  = @work_dir.join('answers')
    @output_file = @answer_dir.join "#{@machine.name}.txt"

    set_template_path
  end

  def generate
    @logger.info "Writing answers file for #{@machine.inspect} to #{@output_file}"
    @answer_dir.mkpath unless @answer_dir.exist?

    @output_file.open('w') { |fh| fh.write(render_answers) }
  end

  def render_answers
    answer_template = template_data
    unless @config.answer_extras.empty?
      answer_template += ("\n" + @config.answer_extras.map {|e| e.to_s}.join("\n") + "\n")
    end

    ERB.new(answer_template).result(binding)
  end

  private

  def set_template_path
    if @config.answer_file
      @template = @config.answer_file
      mode = 'explicit'
    else
      release_info = PEBuild::Release[@config.version.split('-').first]

      @template = release_info.answer_file(@config.role)
      mode = 'default'
    end

    @logger.info "Using #{mode} answers file template #{@template} for #{@machine.inspect}"
  end

  # Separated for easy stubbing in spec tests.
  def template_data
    File.read(@template)
  end

  def machine_hostname
    @machine.config.vm.hostname || @machine.name
  end
end
