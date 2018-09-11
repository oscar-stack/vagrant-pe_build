require 'config_builder/model'

# @since 0.13.0
class PEBuild::ConfigBuilder::PEAgent < ::ConfigBuilder::Model::Provisioner::Base
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
  #     If {#master_vm} is set, the hostname of that machine will be used
  #     as a default. If the hostname is unset, the name of the VM will be
  #     used as a secondary default.
  def_model_attribute :master
  # @!attribute master_vm
  #   @return [String] The name of a Vagrant VM to use as the master.
  def_model_attribute :master_vm
  # @!attribute version
  #   @return [String] The version of PE to install. May be either a version
  #   string of the form `x.y.x[-optional-arbitrary-stuff]` or the string
  #   `current`. Defaults to `current`.
  def_model_attribute :version
  # @!attribute agent_type
  #   @return [String] The type of agent installation this will be.
  #   This allows for configuring the agent as an infrastructure component.
  #   May be either `compile`, `replica, or `agent`.
  #   Defaults to `agent`.
  def_model_attribute :agent_type

  ::ConfigBuilder::Model::Provisioner.register('pe_agent', self)
end
