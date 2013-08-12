require 'pe_build/version'
require 'pe_build/idempotent'

require 'open-uri'
require 'progressbar'

class PEBuild::Transfer::HTTP

  # @param src [String] The URL to the file to copy
  # @param dst [String] The path to destination of the copied file
  def initialize(src, dst)
    @src, @dst = src, dst

    @logger = Log4r::Logger.new('vagrant::pe_build::transfer::http')
  end

  include PEBuild::Idempotent

  def copy
    idempotent do
      tmpfile = download_file
      FileUtils.mv(tmpfile, @dst)
    end
  end

  HEADERS = {'User-Agent' => "Vagrant/PEBuild (v#{PEBuild::VERSION})"}

  private

  # Open a open-uri file handle for the given URL
  #
  # @return [IO]
  def download_file
    progress = nil

    content_length_proc = lambda do |length|
      if length and length > 0
        progress = ProgressBar.new('Fetching file', length)
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

    @logger.info "Fetching file from #{@uri}"

    @uri.open(options)
  end
end
