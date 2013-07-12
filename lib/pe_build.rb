require 'vagrant'

module PEBuild

  # Return the path to the archived PE builds
  #
  # @param env [Vagrant::Environment]
  def self.archive_directory(env)
    File.expand_path('pe_builds', env.home_path)
  end

  def self.source_root
    File.expand_path('..', File.dirname(__FILE__))
  end

  def self.template_dir
    File.expand_path('templates', source_root)
  end
end

# I18n to load the en locale
I18n.load_path << File.expand_path("locales/en.yml", PEBuild.template_dir)

require 'pe_build/plugin'
require 'pe_build/version'
