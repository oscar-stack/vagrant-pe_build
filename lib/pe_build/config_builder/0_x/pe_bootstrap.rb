require 'config_builder/model'

class PEBuild::ConfigBuilder::PEBootstrap < ::PEBuild::ConfigBuilder::Global

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

  def to_proc
    Proc.new do |vm_config|
      vm_config.provision :pe_bootstrap do |pe|
        # Globally settable attributes
        with_attr(:download_root) { |val| pe.download_root = val }
        with_attr(:version)       { |val| pe.version       = val }
        with_attr(:version_file)  { |val| pe.version_file  = val }
        with_attr(:series)        { |val| pe.series        = val }
        with_attr(:suffix)        { |val| pe.suffix        = val }
        with_attr(:filename)      { |val| pe.filename      = val }
        with_attr(:shared_installer) { |val| pe.shared_installer = val }

        with_attr(:role)               { |val| pe.role               = val }
        with_attr(:verbose)            { |val| pe.verbose            = val }
        with_attr(:master)             { |val| pe.master             = val }
        with_attr(:answer_file)        { |val| pe.answer_file        = val }
        with_attr(:answer_extras)      { |val| pe.answer_extras      = val }
        with_attr(:relocate_manifests) { |val| pe.relocate_manifests = val }
        with_attr(:autosign)           { |val| pe.autosign           = val }
      end
    end
  end

  ::ConfigBuilder::Model::Provisioner.register('pe_bootstrap', self)
end
