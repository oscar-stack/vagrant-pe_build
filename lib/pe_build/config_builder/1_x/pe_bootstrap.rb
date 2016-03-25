require 'config_builder/model'

class PEBuild::ConfigBuilder::PEBootstrap < ::ConfigBuilder::Model::Provisioner::Base

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

  # @!attribute shared_installer
  #   @return [Boolean] Whether to run PE installation using installers and
  #     answers shared using the `/vagrant` mount. If set to `false`, resources
  #     will be downloaded remotely to the home directory of whichever user
  #     account Vagrant is using. Defaults to `true`.
  #
  #   @since 0.14.0
  def_model_attribute :shared_installer

  # @!attribute [rw] role
  #   @return [Symbol] The role of the Puppet Enterprise install.
  def_model_attribute :role

  # @!attribute [rw] verbose
  #   @return [Boolean] Whether or not to show the verbose output of the Puppet
  #     Enterprise install.
  def_model_attribute :verbose

  # @!attribute [rw] master
  #   @return [String] The address of the puppet master.
  def_model_attribute :master

  # @!attribute [rw] answer_file
  #   @return [String] The location of alternate answer file for PE
  #     installation. Values can be paths relative to the Vagrantfile's project
  #     directory.
  def_model_attribute :answer_file

  # @!attribute answer_extras
  #   @return [Array<String>] An array of additional answer strings that will
  #     be appended to the answer file. (Optional)
  #   @since 0.11.0
  def_model_attribute :answer_extras

  # @!attribute [rw] relocate_manifests
  #   @return [Boolean] Whether or not to change the PE master to use a config
  #     of manifestdir=/manifests and modulepath=/modules. This is meant to be
  #     used when the vagrant working directory manifests and modules are
  #     remounted on the guest.
  def_model_attribute :relocate_manifests

  # @!attribute [rw] autosign
  #   Configure the certificates that will be autosigned by the puppet master.
  #
  #   @return [TrueClass] All CSRs will be signed
  #   @return [FalseClass] The autosign config file will be unmanaged
  #   @return [Array<String>] CSRs with the given addresses
  #
  #   @see http://docs.puppetlabs.com/guides/configuring.html#autosignconf
  #
  #   @since 0.4.0
  def_model_attribute :autosign

  ::ConfigBuilder::Model::Provisioner.register('pe_bootstrap', self)
end
