require 'fileutils'
require 'pe_build/idempotent'

# @todo These methods fail in a messy way if something goes wrong. They should
#   be refactored to raise proper errors.
# @api private
module PEBuild::Transfer::File
  extend PEBuild::Idempotent

  # @param src [URI] The local file path path to the file to copy
  # @param dst [String] The path to destination of the copied file
  def self.copy(src, dst)
    idempotent(dst) { FileUtils.cp src.path, dst }
  end

  # @param src [URI] The local file path path to the file to read
  # @return [String] The contents of the file with leading and trailing
  #   whitespace removed.
  #
  # @since 0.9.0
  def self.read(src)
    File.read(src.path).strip
  end

  # TODO: Raise an appropriate exception when files do not exist.
end
