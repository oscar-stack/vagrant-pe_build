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

    # Return the contents of a local or remote file.
    #
    # @param src [URI] The URI of the source file.
    # @raise [UnhandledURIScheme] If the URI uses an unsupported scheme.
    # @return [String] The contents of the source file.
    #
    # @since 0.9.0
    def self.read(src)
      scheme = src.scheme

      if (mod = IMPLEMENTATIONS[scheme])
        mod.read(src)
      else
        raise UnhandledURIScheme, :scheme => scheme,
                                  :supported => IMPLEMENTATIONS.keys
      end
    end
  end
end
