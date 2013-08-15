module PEBuild
  module Transfer

    class UnhandledURIScheme < Vagrant::Errors::Error
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

    def self.generate(src, dst)
      scheme = src.scheme

      if (klass = IMPLEMENTATIONS[scheme])
        klass.new(src, dst)
      else
        raise UnhandledURIScheme, :scheme => scheme,
                                  :supported => IMPLEMENTATIONS.keys
      end
    end
  end
end

