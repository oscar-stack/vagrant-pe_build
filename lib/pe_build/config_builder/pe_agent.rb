require 'config_builder/model'

# @since 0.13.0
class PEBuild::ConfigBuilder::PEAgent < ::ConfigBuilder::Model::Base
  # @!attribute master
  #   @return [String] The DNS hostname of the Puppet master for this node.
  def_model_attribute :master
  def_model_attribute :master_vm
  # @!attribute version
  #   @return [String] The version of PE to install. May be either a version
  #   string of the form `x.y.x[-optional-arbitrary-stuff]` or the string
  #   `current`. Defaults to `current`.
  def_model_attribute :version

  def to_proc
    Proc.new do |vm_config|
      vm_config.provision :pe_agent do |config|
        with_attr(:master)   {|val| config.master = val }
        with_attr(:master_vm){|val| config.master_vm = val }
        with_attr(:version)  {|val| config.version  = val }
      end
    end
  end

  ::ConfigBuilder::Model::Provisioner.register('pe_agent', self)
end
