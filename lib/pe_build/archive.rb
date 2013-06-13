require 'pe_build'
require 'fileutils'

require 'tempfile'
require 'open-uri'
require 'progressbar'


module PEBuild
class Archive
  # Represents a packed Puppet Enterprise archive
  #
  # @todo Segregate logic around downloading file
  # @todo Add logic for copying file from local source
  # @todo replace curl with 'open-uri'

  # @!attribute [rw] version
  #   @return [String] The version of Puppet Enterprise
  attr_accessor :version

  # @!attribute [rw] filename
  #   @return [String] The filename. Thing
  attr_accessor :filename

  attr_accessor :ui

  def initialize(filename, version, ui)
    @ui       = ui
    @version  = version
    @filename = filename.gsub(/:version/, @version)

    @archive_path = File.join(PEBuild.archive_directory, @filename)
    @url = "#{@download_dir}/#{@filename}"
  end

  def copy_from(fs_dir)
    if File.exist? @archive_path
      @ui.info "#{@filename} cached, skipping copy."
    else
      prepare_for_copy!

      file_path = File.join(fs_dir, filename)

      FileUtils.cp file_path, @archive_path
    end
  end

  HEADERS = {'User-Agent' => "Vagrant/PEBuild (v#{PEBuild::VERSION})"}

  # @todo Download to tempfile, and move into place when download complete
  def download_from(download_dir)

    if File.exist? @archive_path
      @ui.info "#{@filename} cached, skipping download."
    else
      prepare_for_copy!

      str = "#{download_dir}/#{@filename}"
      str.gsub!(':version', @version)

      tmpfile = open_uri(str)

      FileUtils.mv tmpfile, @archive_path
    end
  end

  private

  # @todo hackish. Remove.
  def prepare_for_copy!
    archive_dir = PEBuild.archive_directory
    if not File.directory? archive_dir
      FileUtils.mkdir_p archive_dir
    end
  end

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
end
end
