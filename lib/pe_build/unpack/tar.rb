require 'archive/tar/minitar'
require 'zlib'

module PEBuild
module Unpack
class Tar

  # @param src [String]
  # @param dst [String]
  def initialize(src, dst)
    @src, @dst = src, dst
  end

  def unpack
    ::Archive::Tar::Minitar.unpack(zip, @dst)
  end

  # @return [String] The base directory contained in the tar archive
  def dirname
    input = ::Archive::Tar::Minitar::Input.new(zip)

    base = nil
    input.each do |entry|
      path = entry.name
      base = path.split(File::SEPARATOR).first
    end

    base
  end

  private

  def zip
    Zlib::GzipReader.new(File.open(@src, 'rb'))
  end
end
end
end
