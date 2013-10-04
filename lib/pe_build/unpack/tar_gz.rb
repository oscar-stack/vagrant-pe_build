require 'pe_build/unpack'
require 'pe_build/unpack/tar'

require 'zlib'

class PEBuild::Unpack::TarGZ < PEBuild::Unpack::Tar

  private

  def file_stream
    Zlib::GzipReader.new(super)
  end
end
