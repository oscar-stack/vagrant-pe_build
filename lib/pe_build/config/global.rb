require 'uri'
require 'vagrant'

require 'pe_build/config_default'

module PEBuild
module Config

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

  # Allow our filename default to use @version and @suffix variables. This
  # approach will not break the merging mechanism since the merging directly
  # accesses the instance variables of the configuration objects.
  def filename
    if @filename == UNSET_VALUE
      "puppet-enterprise-#{version}-#{suffix}.tar.gz"
    else
      @filename
    end
  end

  # @!attribute filename
  attr_writer :filename

  def initialize
    @download_root = UNSET_VALUE
    @version       = UNSET_VALUE
    @suffix        = UNSET_VALUE
    @filename      = UNSET_VALUE
  end

  include PEBuild::ConfigDefault

  def finalize!
    set_default :@suffix,   'all'
    #set_default :@version,  DEFAULT_PE_VERSION

    set_default :@download_root, nil
  end

  # @todo Convert error strings to I18n
  def validate(machine)
    errors = []

    # Allow Global version to be unset, rendering it essentially optional. If it is
    # discovered to be unset by a configuration on the next level up who cannot provide a
    # value, it is that configuration's job to take action.
    if @version.kind_of? String
      unless @version.match /\d+\.\d+(\.\d+)?/
        errors << "version must be a valid version string, got #{@version.inspect}"
      end
    elsif @version != UNSET_VALUE
      errors << "version only accepts a string, got #{@version.class}"
    end

    uri = URI.parse(@download_root) rescue nil
    unless @download_root == UNSET_VALUE or @download_root.nil? or File.directory?(File.expand_path(@download_root)) or uri.kind_of? (URI::HTTP||URI::HTTPS) or uri.kind_of? URI::FTP
      errors << "download_root must be valid URL or present local file path, got #{@download_root}"
    end

    {"PE Build global config" => errors}
  end
end

end
end
