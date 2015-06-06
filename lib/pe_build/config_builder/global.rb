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

  # @!attribute [rw] series
  #   @return [String] The release series of PE. Completely optional and
  #     currently has no effect other than being an interpolation token
  #     available for use in {#download_root}.
  #
  #   @since 0.9.0
  def_model_attribute :series

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
      with_attr(:download_root) { |val| global_config.pe_build.download_root = val }
      with_attr(:version)       { |val| global_config.pe_build.version       = val }
      with_attr(:version_file)  { |val| global_config.pe_build.version_file  = val }
      with_attr(:series)        { |val| global_config.pe_build.series        = val }
      with_attr(:suffix)        { |val| global_config.pe_build.suffix        = val }
      with_attr(:filename)      { |val| global_config.pe_build.filename      = val }
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
