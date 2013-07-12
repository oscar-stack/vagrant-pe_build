require 'pe_build'
require 'pe_build/idempotent'

require 'pe_build/transfer/file'
require 'pe_build/transfer/uri'

require 'pe_build/unpack/tar'

require 'fileutils'

module PEBuild

class ArchiveNoInstallerSource < Vagrant::Errors::VagrantError
  error_key(:no_installer_source, "pebuild.archive")
end

class Archive
  # Represents a packed Puppet Enterprise archive

  include PEBuild::Idempotent

  # @!attribute [rw] version
  #   @return [String] The version of Puppet Enterprise
  attr_accessor :version

  # @!attribute [rw] filename
  #   @return [String] The filename. Thing
  attr_accessor :filename

  attr_accessor :env

  # @param filename [String] The uninterpolated filename
  # @param env [Hash]
  def initialize(filename, env)
    @filename = filename
    @env      = env
  end

  # @param fs_dir [String] The base directory to extract the installer to
  def unpack_to(fs_dir)
    tar  = PEBuild::Unpack::Tar.new(archive_path, fs_dir)
    path = File.join(fs_dir, tar.dirname)

    idempotent(path, "Unpacked archive #{filename}") do
      tar.unpack
    end
  end

  # @param fs_dir [String] The base directory holding the archive
  def copy_from(fs_dir)
    file_path = versioned_path(File.join(fs_dir, filename))

    idempotent(archive_path, "Installer #{versioned_path @filename}") do
      prepare_for_copy!
      transfer = PEBuild::Transfer::File.new(file_path, archive_path)
      transfer.copy
    end
  end

  # @param download_dir [String] The URL base containing the archive
  def download_from(download_dir)
    idempotent(archive_path, "Installer #{versioned_path @filename}") do
      if download_dir.nil?
        @env.ui.error "Installer #{versioned_path @filename} is not available."

        archive_dir = PEBuild.archive_directory(@env)

        collection = PEBuild::ArchiveCollection.new(archive_dir, @env)
        collection.display

        raise PEBuild::ArchiveNoInstallerSource
      else
        str = versioned_path("#{download_dir}/#{@filename}")

        prepare_for_copy!
        transfer = PEBuild::Transfer::URI.new(str, archive_path)
        transfer.copy
      end
    end
  end

  private

  # Initialize the PE directory
  #
  # @todo respect Vagrant home setting
  def prepare_for_copy!
    archive_dir = PEBuild.archive_directory(@env)

    if not File.directory? archive_dir
      FileUtils.mkdir_p archive_dir
    end
  end


  # @return [String] The interpolated archive path
  def archive_path
    archive_dir = PEBuild.archive_directory(@env)
    path = File.join(archive_dir, @filename)
    versioned_path(path)
  end

  def versioned_path(path)
    if @version
      path.gsub(/:version/, @version)
    else
      path
    end
  end
end
end
