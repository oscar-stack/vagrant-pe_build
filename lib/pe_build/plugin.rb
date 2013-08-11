require 'vagrant'
require 'pe_build/version'

if Vagrant::VERSION < "1.1.0"
  raise "vagrant-pe_build version #{PEBuild::VERSION} requires Vagrant 1.1 or later"
end

module PEBuild
  class Plugin < Vagrant.plugin('2')

    name 'pe_build'

    description <<-DESC
    This plugin adds commands and provisioners to automatically install Puppet
    Enterprise on Vagrant guests.
    DESC

    config(:pe_bootstrap, :provisioner) do
      require_relative 'config/pe_bootstrap'
      PEBuild::Config::PEBootstrap
    end

    config(:pe_build) do
      require_relative 'config/global'
      PEBuild::Config::Global
    end

    provisioner(:pe_bootstrap) do
      require_relative 'provisioner/pe_bootstrap'
      PEBuild::Provisioner::PEBootstrap
    end

    command(:'pe-build') do
      require_relative 'command'
      PEBuild::Command::Base
    end
  end
end
