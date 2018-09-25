require 'pe_build/util/version_string'

# Configuration for PE Agent provisioners
#
# @since 0.13.0
class PEBuild::Config::PEAgent < Vagrant.plugin('2', :config)
  # The minimum PE Version supported by this provisioner.
  MINIMUM_VERSION    = '2015.2.0'

  # @!attribute [rw] autosign
  #   If true, and {#master_vm} is set, the agent's certificate will be signed
  #   on the master VM.
  #
  #   @return [true, false] Defaults to `true` if {#master_vm} is set,
  #     otherwise `false`.
  attr_accessor :autosign

  # @!attribute [rw] autopurge
  #   If true, and {#master_vm} is set, the agent's certificate and data will
  #   be purged from the master VM if the agent is destroyed by Vagrant.
  #
  #   @return [true, false] Defaults to `true` if {#master_vm} is set,
  #     otherwise `false`.
  attr_accessor :autopurge

  # @!attribute master
  #   @return [String] The DNS hostname of the Puppet master for this node.
  #     If {#master_vm} is set, the hostname of that machine will be used
  #     as a default. If the hostname is unset, the name of the VM will be
  #     used as a secondary default.
  attr_accessor :master

  # @!attribute master_vm
  #   @return [String] The name of a Vagrant VM to use as the master.
  attr_accessor :master_vm

  # @!attribute version
  #   @return [String] The version of PE to install. May be either a version
  #   string of the form `x.y.x[-optional-arbitrary-stuff]` or the string
  #   `current`. Defaults to `current`.
  attr_accessor :version

  # @!attribute agent_type
  #   @return [String] The type of agent installation this will be. 
  #   This allows for configuring the agent as an infrastructure component.
  #   May be either `compile`, `replica, or `agent`.
  #   Defaults to `agent`.
  attr_accessor :agent_type

  def initialize
    @autosign      = UNSET_VALUE
    @autopurge     = UNSET_VALUE
    @master        = UNSET_VALUE
    @master_vm     = UNSET_VALUE
    @version       = UNSET_VALUE
    @agent_type    = UNSET_VALUE
  end

  def finalize!
    @master        = nil if @master == UNSET_VALUE
    @master_vm     = nil if @master_vm == UNSET_VALUE
    @autosign      = (not @master_vm.nil?) if @autosign  == UNSET_VALUE
    @autopurge     = (not @master_vm.nil?) if @autopurge == UNSET_VALUE
    @version       = 'current' if @version == UNSET_VALUE
    @agent_type    = 'agent' if @agent_type == UNSET_VALUE
  end

  def validate(machine)
    errors = _detected_errors

    if @master.nil? && @master_vm.nil?
      errors << I18n.t('pebuild.config.pe_agent.errors.no_master')
    end

    validate_master_vm!(errors, machine)
    validate_version!(errors, machine)
    validate_agent_type!(errors, machine)

    {'pe_agent provisioner' => errors}
  end

  private

  def validate_master_vm!(errors, machine)
    if (not @master_vm.nil?) && (not machine.env.machine_names.include?(@master_vm.intern))
      errors << I18n.t(
        'pebuild.config.pe_agent.errors.master_vm_not_defined',
        :vm_name  => @master_vm
      )
    end

    if @autosign && @master_vm.nil?
      errors << I18n.t(
        'pebuild.config.pe_agent.errors.master_vm_required',
        :setting  => 'autosign'
      )
    end

    if @autopurge && @master_vm.nil?
      errors << I18n.t(
        'pebuild.config.pe_agent.errors.master_vm_required',
        :setting  => 'autopurge'
      )
    end
  end

  def validate_version!(errors, machine)
    pe_version_regex = %r[\d+\.\d+\.\d+[\w-]*]

    if @version.kind_of? String
      return if version == 'current'
      if version.match(pe_version_regex)
        unless PEBuild::Util::VersionString.compare(@version, MINIMUM_VERSION) >= 0
          errors << I18n.t(
            'pebuild.config.pe_agent.errors.version_too_old',
            :version         => @version,
            :minimum_version => MINIMUM_VERSION
          )
        end

        return
      end
    end

    # If we end up here, the version was not a string that matched 'current' or
    # the regex. Mutate the error array.
    errors << I18n.t(
      'pebuild.config.pe_agent.errors.malformed_version',
      :version       => @version,
      :version_class => @version.class
    )
  end

  def validate_agent_type!(errors, machine)

      unless ['agent','replica','compile'].include?(@agent_type)
        errors << I18n.t(
          'pebuild.config.pe_agent.errors.agent_type_invalid',
          :type         => @agent_type,
        )
      end

      if @agent_type == 'replica' and PEBuild::Util::VersionString.compare(@version, '2016.5.0') < 0
        errors << I18n.t(
          'pebuild.config.pe_agent.errors.agent_type_version_too_old',
          :version         => @version,
          :minimum_version => '2016.5.0',
          :agent_type      => @agent_type
        )
      elsif @agent_type == 'compile' and PEBuild::Util::VersionString.compare(@version, '2016.1.0') < 0
        errors << I18n.t(
          'pebuild.config.pe_agent.errors.agent_type_version_too_old',
          :version         => @version,
          :minimum_version => '2016.1.0',
          :agent_type      => @agent_type
        )
      end

      return
  end
end
