require 'vagrant'

module PEBuild
module Config

class Global < Vagrant.plugin('2', :config)

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

    %w[suffix version filename download_root].each do |iv|
      iv_val = instance_variable_get("@#{iv}")
      unless iv_val == UNSET_VALUE
        errors << "pe_build.#{iv} as a global config value is deprecated. Specify this value on a per-provisioner basis."
      end
    end

    {"PE Build global config" => errors}
  end
end

end
end
