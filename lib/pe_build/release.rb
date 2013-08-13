module PEBuild
  module Release

    require 'pe_build/release/instance'

    @releases = {}

    def self.[](ver)
      @releases[ver]
    end

    def self.newrelease(&blk)
      PEBuild::Release::Instance.new(&blk)
    end
  end
end
