module PEBuild
  module Transfer
    require 'pe_build/transfer/http'
    require 'pe_build/transfer/file'

    IMPLEMENTATIONS = {
      'http'  => PEBuild::Transfer::HTTP,
      'https' => PEBuild::Transfer::HTTP,
      'file'  => PEBuild::Transfer::File,
    }

    def self.generate(src, dst)
      schema = src.schema

      if (klass = IMPLEMENTATION[schema])
        klass.new(src, dst)
      else
        raise "Schema #{schema.inspect} cannot be handled by any file transferrers"
      end
    end
  end
end

