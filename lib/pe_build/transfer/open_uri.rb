require 'pe_build/version'
require 'pe_build/idempotent'

require 'open-uri'
require 'ruby-progressbar'

# @api private
module PEBuild::Transfer::OpenURI
  extend PEBuild::Idempotent

  HEADERS = {'User-Agent' => "Vagrant/PEBuild (v#{PEBuild::VERSION})"}

  class DownloadFailed < Vagrant::Errors::VagrantError
    error_key(:download_failed, 'pebuild.transfer.open_uri')
  end

  # @param uri [URI]    The http(s) URI to the file to copy
  # @param dst [String] The path to destination of the copied file
  def self.copy(uri, dst)
    idempotent(dst) do
      tmpfile = download_file(uri)
      # Ensure the file is closed after the download. On Windows, leaving the
      # file open will prevent it from being moved.
      tmpfile.close()
      FileUtils.mv(tmpfile, dst)
    end
  rescue StandardError => e
    raise DownloadFailed, :uri => uri, :msg => e.message
  end

  # @param uri [URI] The http(s) URI to the file to copy
  # @return [String] The contents of the file with leading and trailing
  #   whitespace removed.
  #
  # @since 0.9.0
  def self.read(uri)
    uri.read(HEADERS.merge({'Accept' => 'text/plain'})).strip
  rescue StandardError => e
    raise DownloadFailed, :uri => uri, :msg => e.message
  end

  # Open a open-uri file handle for the given URL
  #
  # @param uri [URI]
  # @return [IO]
  def self.download_file(uri)
    progress = nil
    downloaded = 0

    content_length_proc = lambda do |length|
      if length and length > 0
        STDERR.puts "Fetching: #{uri}"
        progress = ProgressBar.create(
          :title => "Fetching file",
          :total => length,
          :output => STDERR,
          :format => '%t: %p%% |%b>%i| %e')
      end
    end

    progress_proc = lambda do |size|
      unless progress.nil?
        progress.progress += (size - downloaded)
        downloaded = size
      end
    end

    options = HEADERS.merge({
      :content_length_proc => content_length_proc,
      :progress_proc       => progress_proc,
    })

    uri.open(options)
  ensure
    progress.stop unless progress.nil?
  end
end
