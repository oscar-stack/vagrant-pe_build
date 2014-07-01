require 'pe_build/config_default'
require 'pe_build/transfer'

require 'uri'

class PEBuild::Config::Global < Vagrant.plugin('2', :config)

  # @!attribute download_root
  #   @return [String] The root URI from which to download packages. The URI
  #     scheme must be one of the values listed in {PEBuild::Transfer::IMPLEMENTATIONS}.
  #   @since 0.1.0
  attr_accessor :download_root

  # @!attribute version
  #   @return [String] The version of PE to install. Must conform to
  #     `x.y.x[-optional-arbitrary-stuff]`. Ignored if {#filename} is set.
  #   @since 0.1.0
  attr_accessor :version

  # @!attribute suffix
  #   @return [String] The distribution specifix suffix of the Puppet
  #     Enterprise installer to use.
  #   @since 0.1.0
  attr_accessor :suffix

  # @!attribute filename
  #   @return [String] The exact name of the PE installer archive. Overrides
  #     {#version} if set.
  #   @since 0.1.0
  attr_accessor :filename

  def initialize
    @download_root = UNSET_VALUE
    @version       = UNSET_VALUE
    @suffix        = UNSET_VALUE
    @filename      = UNSET_VALUE
  end

  include PEBuild::ConfigDefault

  def finalize!
    set_default :@suffix, :detect
    set_default :@download_root, nil
    set_default :@filename, nil
  end

  def validate(machine)
    errors = []

    validate_version(errors, machine)
    validate_download_root(errors, machine)

    {"PE build global config" => errors}
  end

  private

  PE_VERSION_REGEX = %r[\d+\.\d+\.\d+[\w-]*]

  def validate_version(errors, machine)

    errmsg = I18n.t(
      'pebuild.config.global.errors.malformed_version',
      :version       => @version,
      :version_class => @version.class
    )

    # Allow Global version to be unset, rendering it essentially optional. If it is
    # discovered to be unset by a configuration on the next level up who cannot provide a
    # value, it is that configuration's job to take action.
    if @version.kind_of? String
      if !(@version.match PE_VERSION_REGEX)
        errors << errmsg
      end
    elsif @version != UNSET_VALUE
      errors << errmsg
    end
  end

  def validate_download_root(errors, machine)
    if @download_root and @download_root != UNSET_VALUE
      begin
        uri = URI.parse(@download_root)

        if PEBuild::Transfer::IMPLEMENTATIONS[uri.scheme].nil?
          errors << I18n.t(
            'pebuild.config.global.errors.unhandled_download_root_scheme',
            :download_root => @download_root,
            :scheme        => uri.scheme,
            :supported     => PEBuild::Transfer::IMPLEMENTATIONS.keys
          )
        end
      rescue URI::InvalidURIError
        errors << I18n.t('pebuild.config.global.errors.invalid_download_root_uri')
      end
    end
  end
end
