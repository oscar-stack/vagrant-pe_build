require 'archive/tar/minitar'

module PEBuild
class Archive
class Unpacker

  # @param src [String]
  # @param dst [String]
  def initialize(src, dst)
    @src, @dst = src, dst
  end

  def unpack
    Archive::Tar::Minitar.unpack(@src, @dst)
  end
end
end
end
