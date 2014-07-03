require 'config_builder/model'

class PEBuild::ConfigBuilder::Global < ::ConfigBuilder::Model::Base

  # @!attribute [rw] version
  #   @return [String] The version of Puppet Enterprise to install.
  def_model_attribute :version

  # @!attribute [rw] version_file
  #   @return [String] The path to a file relative to {#download_root}. The
  #     contents of this file will be read and used to specify {#version}.
  #   @since 0.9.0
  def_model_attribute :version_file

  def_model_attribute :release

  # @!attribute [rw] suffix
  #   @return [String] The distribution specifix suffix of the Puppet
  #     Enterprise installer to use.
  def_model_attribute :suffix

  # @!attribute [rw] filename
  #   @return [String] The filename of the Puppet Enterprise installer.
  def_model_attribute :filename

  # @!attribute [rw] download_root
  #   @return [String] The URI to the directory containing Puppet Enterprise
  #     installers if the installer is not yet cached. This setting is optional.
  def_model_attribute :download_root

  def to_proc
    Proc.new do |global_config|
      global_config.pe_build.download_root = attr(:download_root) if attr(:download_root)
      global_config.pe_build.version       = attr(:version)       if attr(:version)
      global_config.pe_build.version_file  = attr(:version_file)  if attr(:version_file)
      global_config.pe_build.suffix        = attr(:suffix)        if attr(:suffix)
      global_config.pe_build.filename      = attr(:filename)      if attr(:filename)
    end
  end
end

class ConfigBuilder::Model::Root
  def_model_delegator :pe_build

  def eval_pe_build(root_config)
    if attr(:pe_build)
      p = PEBuild::ConfigBuilder::Global.new_from_hash(attr(:pe_build))
      p.call(root_config)
    end
  end
  private :eval_pe_build
end
