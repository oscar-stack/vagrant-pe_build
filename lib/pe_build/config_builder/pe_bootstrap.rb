require 'config_builder/model'

class PEBuild::ConfigBuilder::PEBootstrap < ::PEBuild::ConfigBuilder::Global

  def_model_attribute :master
  def_model_attribute :answer_file

  def_model_attribute :verbose

  def_model_attribute :role
  #def_model_attribute :step
  def_model_attribute :relocate_manifests

  def to_proc
    Proc.new do |vm_config|
      vm_config.provision :pe_bootstrap do |pe|
        pe.download_root = attr(:download_root) if attr(:download_root)
        pe.version       = attr(:version)       if attr(:version)
        pe.suffix        = attr(:suffix)        if attr(:suffix)
        pe.filename      = attr(:filename)      if attr(:filename)

        pe.role = attr(:role) if attr(:role)
        pe.relocate_manifests = attr(:relocate_manifests) if attr(:relocate_manifests)
      end
    end
  end

  ::ConfigBuilder::Model::Provisioner.register('pe_bootstrap', self)
end
