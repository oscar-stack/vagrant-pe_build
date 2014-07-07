module PEBuild
  module Transfer

    class UnhandledURIScheme < Vagrant::Errors::VagrantError
      error_key('unhandled_uri_scheme', 'pebuild.transfer')
    end

    require 'pe_build/transfer/open_uri'
    require 'pe_build/transfer/file'

    IMPLEMENTATIONS = {
      'http'  => PEBuild::Transfer::OpenURI,
      'https' => PEBuild::Transfer::OpenURI,
      'ftp'   => PEBuild::Transfer::OpenURI,
      'file'  => PEBuild::Transfer::File,
      nil     => PEBuild::Transfer::File, # Assume that URIs without a scheme are files
    }

    # @param src [URI] The local file path path to the file to copy
    # @param dst [String] The path to destination of the copied file
    def self.copy(src, dst)
      scheme = src.scheme

      if (mod = IMPLEMENTATIONS[scheme])
        mod.copy(src, dst)
      else
        raise UnhandledURIScheme, :scheme => scheme,
                                  :supported => IMPLEMENTATIONS.keys
      end
    end
  end
end
