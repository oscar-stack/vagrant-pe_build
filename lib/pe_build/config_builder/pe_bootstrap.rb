require 'config_builder/model'

class PEBuild::ConfigBuilder::PEBootstrap < ::ConfigBuilder::Model::Base

  def_model_attribute :master
  def_model_attribute :answer_file

  def_model_attribute :verbose

  def_model_attribute :role
  #def_model_attribute :step
  def_model_attribute :relocate_manifests

  def to_proc
    Proc.new do |vm_config|
      vm_config.provision :pe_bootstrap do |pe|
        pe.role = attr(:role) if attr(:role)
        pe.relocate_manifests = attr(:relocate_manifests) if attr(:relocate_manifests)
      end
    end
  end

  ::ConfigBuilder::Model::Provisioner.register('pe_bootstrap', self)
end
