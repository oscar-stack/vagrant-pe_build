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

    require 'pe_build/release/2_0'
    require 'pe_build/release/2_5'
    require 'pe_build/release/2_6'
    require 'pe_build/release/2_7'
    require 'pe_build/release/2_8'
    require 'pe_build/release/3_0'

    LATEST_VERSION = '3.0.1'
  end
end
