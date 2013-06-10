require 'pe_build'
require 'fileutils'

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

  # @todo Take download_dir as an argument; don't presuppose that we will be
  #   downloading every file.
  # @todo Download to tempfile, and move into place when download complete
  # @todo better handling of @ui variable; should probably be a mandatory arg
  def download(download_dir)

    if File.exist? @archive_path
      # @ui IS NOT REQUIRED. IT WILL BLOW UP IF MISSING.
      @ui.info "#{@filename} cached, skipping download."
    else
      mk_archive_dir

      url = "#{download_dir}/#{@filename}"
      url.gsub!(':version', @version)

      cmd = %{curl -L -A "Vagrant/PEBuild (v#{PEBuild::VERSION})" -O #{url}}
      @ui.info "Executing '#{cmd}'"
      Dir.chdir(PEBuild.archive_directory) { %x{#{cmd}} }
    end
  end

  private

  # @todo hackish. Remove.
  def mk_archive_dir
    archive_dir = PEBuild.archive_directory
    if not File.directory? archive_dir
      FileUtils.mkdir_p archive_dir
    end
  end
end
end
