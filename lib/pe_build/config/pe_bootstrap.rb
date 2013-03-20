require 'vagrant'

module PEBuild; module Config

class PEBootstrap < Vagrant.plugin('2', :config)

  # @!attribute master
  #   @return The DNS hostname of the Puppet master for this node.
  attr_writer :master

  # @!attribute answers
  #   @return [String] The path to a user specified answers file (Optional)
  attr_writer :answers

  # @!attribute verbose
  #   @return [TrueClass, FalseClass] if stdout will be displayed when installing


  VALID_ROLES = [:agent, :master]

  # @!attribute role
  #   @return [Symbol] The type of the PE installation role. One of [:master, :agent]
  attr_writer :role

  # @!attribute step
  #   @return [Hash<Symbol, String>] a hash whose keys are step levels, and whose
  #                                  keys are directories to optional steps.
  attr_writer :steps

  def initialize
    @role    = UNSET_VALUE
    @verbose = UNSET_VALUE
    @master  = UNSET_VALUE
    @answers = UNSET_VALUE

    @step    = {}
  end

  def finalize!
    set_default :@role,    :agent
    set_default :@verbose, false
    set_default :@master,  'master'
    set_default :@answers, "#{@role}.txt"
  end

  def add_step(name, script_path)
    name = (name.is_a?(Symbol)) ? name : name.intern
    step[name] = script_path
  end

  # @todo Convert error strings to I18n
  def validate(machine)
    errors = []

    unless VALID_ROLES.any? {|sym| @role == sym}
      errors << "Role must be one of #{VALID_ROLES.inspect}, was #{@role.inspect}"
    end

    unless @verbose == !!@verbose
      errors << "Verbose must be a boolean, got #{@verbose.class}"
    end

    unless @master.is_a? String
      errors << "Master must be a string, got a #{@master.class}"
    end

    unless File.readable? @answers
      errors << "Answers must be a readable file"
    end

    {"PE Bootstrap" => errors}
  end

  private

  # @param [Symbol] iv The instance variable to set the default value
  # @param [Object] default The default value
  def set_default(iv, default)
    iv_val = instance_variable_get(iv)
    if iv_val == UNSET_VALUE
      instance_variable_set(iv, default)
    end
  end
end

end; end
