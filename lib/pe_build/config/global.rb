require 'vagrant'

module PEBuild; module Config

class Global < Vagrant.plugin('2', :config)

  # @todo This value should be discovered based on what versions of the
  #       installer are cached.
  #DEFAULT_PE_VERSION = '2.7.2'

  # @!attribute download_root
  attr_accessor :download_root

  # @!attribute version
  attr_accessor :version

  # @!attribute suffix
  attr_accessor :suffix

  # @!attribute filename
  attr_accessor :filename

  def initialize
    @download_root = UNSET_VALUE
    @version       = UNSET_VALUE
    @suffix        = UNSET_VALUE
    @filename      = UNSET_VALUE
  end

  def finalize!
    set_default :@suffix,   'all'
    #set_default :@version,  DEFAULT_PE_VERSION
    set_default :@filename, "puppet-enterprise-#{version}-#{suffix}.tar.gz"

    set_default :@download_root, nil
  end

  # @todo Convert error strings to I18n
  def validate(machine)
    errors = []

    unless @version.kind_of? String and @version.match /\d+\.\d+(\.\d+)?/
      errors << "version must be a valid version string, got #{@version.inspect}"
    end

    {"PE Build global config" => errors}
  end

  private

  # @param [Symbol] iv The instance variable to set the default value
  # @param [Object] default The default value
  def set_default(iv, default)
    iv_val = instance_variable_get(iv)
    if iv_val == UNSET_VALUE
      instance_variable_set(iv, default)
    end
  end
end

end; end
