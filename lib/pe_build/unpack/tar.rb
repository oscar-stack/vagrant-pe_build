require 'pe_build/unpack'
require 'archive/tar/minitar'

class PEBuild::Unpack::Tar

  # @param src [String]
  # @param dst [String]
  def initialize(src, dst)
    @src, @dst = src, dst
  end

  def unpack
    ::Archive::Tar::Minitar.unpack(file_stream, @dst)
  end

  # @return [String] The file/dir that will be created as a result of unpack
  def creates
    File.join(@dst, dirname)
  end

  # @return [String] The base directory contained in the tar archive
  def dirname
    input = ::Archive::Tar::Minitar::Input.new(file_stream)

    base = nil
    input.each do |entry|
      path = entry.name
      base = path.split(File::SEPARATOR).first
    end

    base
  end

  private

  def file_stream
    File.open(@src, 'rb')
  end
end
