module PEBuild
  module Transfer
    require 'pe_build/transfer/http'
    require 'pe_build/transfer/file'

    IMPLEMENTATIONS = {
      'http'  => PEBuild::Transfer::HTTP,
      'https' => PEBuild::Transfer::HTTP,
      'file'  => PEBuild::Transfer::File,
      nil     => PEBuild::Transfer::File, # Assume that URIs without a scheme are files
    }

    def self.generate(src, dst)
      scheme = src.scheme

      if (klass = IMPLEMENTATION[scheme])
        klass.new(src, dst)
      else
        raise "URI scheme #{scheme.inspect} cannot be handled by any file transferrers"
      end
    end
  end
end

