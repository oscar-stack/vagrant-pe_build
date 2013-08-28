require 'pe_build/release'

require 'erb'

class PEBuild::Provisioner::PEBootstrap::AnswersFile

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

  private

  def set_template_path
    if @config.answer_file
      @template = @config.answer_file
      mode = 'explicit'
    else
      release_info = PEBuild::Release[@config.version]

      @template = release_info.answer_file(@config.role)
      mode = 'default'
    end

    @logger.info "Using #{mode} answers file template #{@template} for #{@machine.inspect}"
  end

  def render_answers
    template_data = File.read(@template)
    ERB.new(template_data).result(binding)
  end

  def machine_hostname
    @machine.config.vm.hostname || @machine.name
  end
end
