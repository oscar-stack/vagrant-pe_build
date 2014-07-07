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
end
