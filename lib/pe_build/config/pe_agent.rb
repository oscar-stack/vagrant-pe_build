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
  #     as a default.
  attr_accessor :master

  # @!attribute master
  #   @return [String] The name of a Vagrant VM to use as the master.
  attr_accessor :master_vm

  # @!attribute version
  #   @return [String] The version of PE to install. May be either a version
  #   string of the form `x.y.x[-optional-arbitrary-stuff]` or the string
  #   `current`. Defaults to `current`.
  attr_accessor :version

  def initialize
    @autosign      = UNSET_VALUE
    @autopurge     = UNSET_VALUE
    @master        = UNSET_VALUE
    @master_vm     = UNSET_VALUE
    @version       = UNSET_VALUE
  end

  def finalize!
    @master        = nil if @master == UNSET_VALUE
    @master_vm     = nil if @master_vm == UNSET_VALUE
    @autosign      = (not @master_vm.nil?) if @autosign  == UNSET_VALUE
    @autopurge     = (not @master_vm.nil?) if @autopurge == UNSET_VALUE
    @version       = 'current' if @version == UNSET_VALUE
  end

  def validate(machine)
    errors = _detected_errors

    if @master.nil? && @master_vm.nil?
      errors << I18n.t('pebuild.config.pe_agent.errors.no_master')
    end

    validate_master_vm!(errors, machine)
    validate_version!(errors, machine)

    {'pe_agent provisioner' => errors}
  end

  private

  def validate_master_vm!(errors, machine)
    return if @master_vm.nil?

    unless machine.env.machine_names.include?(@master_vm.intern)
      errors << I18n.t(
        'pebuild.config.pe_agent.errors.master_vm_not_defined',
        :vm_name  => @master_vm
      )
    end
  end

  def validate_version!(errors, machine)
    pe_version_regex = %r[\d+\.\d+\.\d+[\w-]*]

    if @version.kind_of? String
      return if version == 'current'
      if version.match(pe_version_regex)
        unless PEBuild::Util::VersionString.compare(@version, MINIMUM_VERSION) > 0
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
end
