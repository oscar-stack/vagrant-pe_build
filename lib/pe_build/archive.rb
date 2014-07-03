require 'pe_build'
require 'pe_build/idempotent'
require 'pe_build/archive_collection'

require 'pe_build/transfer'
require 'pe_build/unpack'

module PEBuild
  class ArchiveNoInstallerSource < Vagrant::Errors::VagrantError
    error_key(:no_installer_source, "pebuild.archive")
  end

  class ArchiveMissing < Vagrant::Errors::VagrantError
    error_key(:missing, "pebuild.archive")
  end

  class ArchiveUnreadable < Vagrant::Errors::VagrantError
    error_key(:unreadable, "pebuild.archive")
  end

  # Represents a packed Puppet Enterprise archive
  class Archive

    include PEBuild::Idempotent

    # @!attribute [rw] version
    #   @return [String] The version of Puppet Enterprise
    attr_accessor :version

    # (see PEBuild::Config::Global#release)
    #
    # @see PEBuild::Config::Global#release
    attr_accessor :release

    # @!attribute [rw] filename
    #   @return [String] The filename. Thing
    attr_accessor :filename

    attr_accessor :env

    # @param filename [String] The uninterpolated filename
    # @param env [Hash]
    def initialize(filename, env)
      @filename = filename
      @env      = env

      @archive_dir = PEBuild.archive_directory(@env)

      @logger = Log4r::Logger.new('vagrant::pe_build::archive')
    end

    # @param base_uri [String] A string representation of the download source URI
    def fetch(str)
      return if self.exist?

      if str.nil?
        @env.ui.error "Cannot fetch installer #{versioned_path @filename}; no download source available."
        @env.ui.error ""
        @env.ui.error "Installers available for use:"

        collection = PEBuild::ArchiveCollection.new(@archive_dir, @env)
        collection.display

        raise PEBuild::ArchiveNoInstallerSource, :filename => versioned_path(@filename)
      end

      uri = URI.parse(versioned_path("#{str}/#{@filename}"))
      dst = File.join(@archive_dir, versioned_path(@filename))

      PEBuild::Transfer.copy(uri, dst)
    end

    # @param fs_dir [String] The base directory to extract the installer to
    def unpack_to(fs_dir)
      unless exist?
        raise PEBuild::ArchiveMissing, :filename => @filename
      end

      archive = PEBuild::Unpack.generate(archive_path, fs_dir)
      begin
        idempotent(archive.creates, "Unpacked archive #{versioned_path filename}") do
          archive.unpack
        end
      rescue Zlib::GzipFile::Error => e
        raise PEBuild::ArchiveUnreadable, :filename => @filename, :message => e.message
      end
    end

    def exist?
      File.exist? archive_path
    end

    def to_s
      versioned_path(@filename)
    end

    def installer_dir
      versioned_path(@filename).gsub(/.tar(?:\.gz)?/, '')
    end

    private

    # @return [String] The interpolated archive path
    def archive_path
      path = File.join(@archive_dir, @filename)
      versioned_path(path)
    end

    def versioned_path(path)
      result = path.dup
      result.gsub!(/:version/, @version) if @version
      result.gsub!(/:release/, @release) if @release

      result
    end
  end
end
