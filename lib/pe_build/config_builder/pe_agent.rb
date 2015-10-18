require 'config_builder/model'

# @since 0.13.0
class PEBuild::ConfigBuilder::PEAgent < ::ConfigBuilder::Model::Base
  # @!attribute [rw] autosign
  #   If true, and {#master_vm} is set, the agent's certificate will be signed
  #   on the master VM.
  #
  #   @return [true, false] Defaults to `true` if {#master_vm} is set,
  #     otherwise `false`.
  def_model_attribute :autosign
  # @!attribute [rw] autopurge
  #   If true, and {#master_vm} is set, the agent's certificate and data will
  #   be purged from the master VM if the agent is destroyed by Vagrant.
  #
  #   @return [true, false] Defaults to `true` if {#master_vm} is set,
  #     otherwise `false`.
  def_model_attribute :autopurge
  # @!attribute master
  #   @return [String] The DNS hostname of the Puppet master for this node.
  def_model_attribute :master
  # @!attribute master_vm
  #   @return [String] The name of a Vagrant VM to use as the master.
  def_model_attribute :master_vm
  # @!attribute version
  #   @return [String] The version of PE to install. May be either a version
  #   string of the form `x.y.x[-optional-arbitrary-stuff]` or the string
  #   `current`. Defaults to `current`.
  def_model_attribute :version

  def to_proc
    Proc.new do |vm_config|
      vm_config.provision :pe_agent do |config|
        with_attr(:autosign)     {|val| config.autosign     = val }
        with_attr(:autopurge)    {|val| config.autopurge    = val }
        with_attr(:master)       {|val| config.master       = val }
        with_attr(:master_vm)    {|val| config.master_vm    = val }
        with_attr(:version)      {|val| config.version      = val }
      end
    end
  end

  ::ConfigBuilder::Model::Provisioner.register('pe_agent', self)
end
