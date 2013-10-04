require 'pe_build/archive'

module PEBuild
  class ArchiveCollection

    #ARCHIVE_REGEX = %r[puppet-enterprise-([\d.])-(.*?)\.(?:tar\.gz|msi)]

    attr_reader :path

    def initialize(path, env)
      @path, @env = path, env
      @archives = []

      load_archives
    end

    def archives
      @archives
    end

    include Enumerable
    def each(&blk)
      @archives.each { |archive| yield archive }
    end

    def display
      @archives.each do |archive|
        @env.ui.info "  - #{archive.filename}"
      end
    end

    private

    def load_archives
      dir = File.join(path, '*')
      Dir.glob(dir).sort.each do |path|
        basename = File.basename(path)
        @archives << PEBuild::Archive.new(basename, @env)
      end
    end
  end
end
