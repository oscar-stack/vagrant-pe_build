require 'vagrant'
require 'uri'
require 'pe_build'

class PEBuild::Config < Vagrant::Config::Base
  attr_writer :download_root
  attr_writer :version
  attr_writer :filename
  attr_writer :suffix

  def download_root
    @download_root
  end

  def version
    @version
  end

  def filename
    @filename
  end

  def suffix
    @suffix || :all
  end

  def validate(env, errors)
    URI.parse(download_root)
  rescue
    # TODO I18n
    errors.add("Invalid download root '#{download_root.inspect}'")
  end
end

Vagrant.config_keys.register(:pe_build) { PEBuild::Config }
