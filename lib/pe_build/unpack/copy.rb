require 'pe_build/unpack'
require 'fileutils'

class PEBuild::Unpack::Copy

  # @param src [String]
  # @param dst [String]
  def initialize(src, dst)
    @src, @dst = src, dst
  end

  def unpack
    FileUtils.cp(@src, creates)
  end

  # @return [String] The file/dir that will be created as a result of unpack
  def creates
    basename = File.basename(@src)
    deploy_path = File.join(@dst, basename)
  end

end
