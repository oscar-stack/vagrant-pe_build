require 'fileutils'

module PEBuild
module Transfer
class File

  # @param src [String] The path to the file to copy
  # @param dst [String] The path to destination of the copied file
  def initialize(src, dst)
    @src, @dst = src, dst
  end

  def copy
    FileUtils.cp @src, @dst
  end
end
end
end
