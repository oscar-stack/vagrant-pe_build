module PEBuild
  module Unpack

    class UnknownInstallerType < Vagrant::Errors::VagrantError
      error_key(:unknown_installer_type, "pebuild.unpack")
    end

    require 'pe_build/unpack/tar'
    require 'pe_build/unpack/tar_gz'
    require 'pe_build/unpack/copy'

    IMPLEMENTATIONS = {
      '.tar'    => PEBuild::Unpack::Tar,
      '.tar.gz' => PEBuild::Unpack::TarGZ,
      '.msi'    => PEBuild::Unpack::Copy,
    }

    # @param src [String]
    # @param dst [String]
    def self.generate(src, dst)
      klass = IMPLEMENTATIONS.find do |key,v|
        src.end_with?(key)
      end.last

      raise UnknownInstallerType, :src => src unless klass
      klass.new(src, dst)
    end

  end
end
