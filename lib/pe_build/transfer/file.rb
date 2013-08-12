require 'fileutils'
require 'pe_build/idempotent'

class PEBuild::Transfer::File

  # @param src [String] The path to the file to copy
  # @param dst [String] The path to destination of the copied file
  def initialize(uri, dst)
    @src = uri.path
    @dst = dst

    @logger = Log4r::Logger.new('vagrant::pe_build::transfer::file')
  end

  include PEBuild::Idempotent

  def copy
    idempotent(@dst) { FileUtils.cp @src, @dst }
  end
end
