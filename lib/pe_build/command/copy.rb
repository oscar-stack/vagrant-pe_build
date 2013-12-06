require 'pe_build/archive'

class PEBuild::Command::Copy < Vagrant.plugin(2, :command)

  def initialize(argv, env)
    super
    @options = {}
  end

  def execute
    argv = parse_options(parser)

    filename = File.basename(argv.last)
    src_dir  = File.dirname(argv.last)

    archive = PEBuild::Archive.new(filename, @env)
    archive.version = @options[:version]

    archive.fetch(src_dir)

    @env.ui.info "pe-build: #{archive} has been added and is ready for use!", :prefix => true
  end

  private

  def parser
    OptionParser.new do |o|
      o.banner = <<-BANNER
      Usage: vagrant pe-build copy installer-uri

      Examples:

          # Copy a local file
          vagrant pe-build copy path/to/installer.tar.gz"

          # Download a file via http
          vagrant pe-build copy http://site-downloads.local/path/to/installer.tar.gz"
      BANNER

      o.separator ''

      o.on('-v', '--version=val', String, "The version of PE to fetch") do |val|
        @options[:version] = val
      end

      o.on('-h', '--help', 'Display this help') do
        puts o
        exit(0)
      end
    end
  end
end
