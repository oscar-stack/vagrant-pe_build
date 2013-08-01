require 'config_builder/model'

class PEBuild::ConfigBuilder::Global < ::ConfigBuilder::Model::Base

  # @!attribute [rw] download_root
  def_model_attribute :download_root

  # @!attribute [rw] version
  def_model_attribute :version

  # @!attribute [rw] suffix
  def_model_attribute :suffix

  # @!attribute [rw] filename
  def_model_attribute :filename

  def to_proc
    Proc.new do |global_config|
      global_config.pe_build.download_root = attr(:download_root) if attr(:download_root)
      global_config.pe_build.version       = attr(:version)       if attr(:version)
      global_config.pe_build.suffix        = attr(:suffix)        if attr(:suffix)
      global_config.pe_build.filename      = attr(:filename)      if attr(:filename)
    end
  end
end

class ConfigBuilder::Model::Root
  def_model_delegator :pe_build

  def eval_pe_build(root_config)
    p = PEBuild::ConfigBuilder::Global.new_from_hash(attr(:pe_build))
    p.call(root_config)
  end
  private :eval_pe_build
end
