require 'pe_build'
require 'fileutils'

require 'tempfile'
require 'open-uri'
require 'progressbar'


module PEBuild
class Archive
  # Represents a packed Puppet Enterprise archive

  # @!attribute [rw] version
  #   @return [String] The version of Puppet Enterprise
  attr_accessor :version

  # @!attribute [rw] filename
  #   @return [String] The filename. Thing
  attr_accessor :filename

  attr_accessor :env

  # @param filename [String] The uninterpolated filename
  # @param env [Vagrant::Environment]
  def initialize(filename, env)
    @env      = env
    @filename = filename

    @url = "#{@download_dir}/#{@filename}"
  end

  # @param fs_dir [String] The base directory to extract the installer to
  def unpack_to(fs_dir)

  end

  # @param fs_dir [String] The base directory holding the archive
  def copy_from(fs_dir)
    if File.exist? @archive_path
      @env.ui.info "#{@filename} cached, skipping copy."
    else
      prepare_for_copy!

      file_path = versioned_path(File.join(fs_dir, filename))

      FileUtils.cp file_path, @archive_path
    end
  end

  # @param download_dir [String] The URL base containing the archive
  def download_from(download_dir)

    if File.exist? @archive_path
      @env.ui.info "#{@filename} cached, skipping download."
    else
      prepare_for_copy!

      str = versioned_path("#{download_dir}/#{@filename}")

      tmpfile = open_uri(str)
      FileUtils.mv tmpfile, @archive_path
    end
  end

  private

  # Initialize the PE directory
  #
  # @todo respect Vagrant home setting
  def prepare_for_copy!
    archive_dir = PEBuild.archive_directory
    if not File.directory? archive_dir
      FileUtils.mkdir_p archive_dir
    end
  end

  HEADERS = {'User-Agent' => "Vagrant/PEBuild (v#{PEBuild::VERSION})"}

  # Open a open-uri file handle for the given URL
  #
  # @param str [String] The URL to open
  #
  # @return [IO]
  def open_uri(str)
    uri = URI.parse(str)
    progress = nil

    content_length_proc = lambda do |length|
      if length and length > 0
        progress = ProgressBar.new(@version, length)
        progress.file_transfer_mode
      end
    end

    progress_proc = lambda do |size|
      progress.set(size) if progress
    end

    options = HEADERS.merge({
      :content_length_proc => content_length_proc,
      :progress_proc       => progress_proc,
    })

    uri.open(options)
  end

  # @return [String] The interpolated archive path
  def archive_path
    path = File.join(PEBuild.archive_directory, @filename)
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
