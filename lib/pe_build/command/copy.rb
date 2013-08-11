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

    archive.copy_from(src_dir)

    @env.ui.info "pe-build: #{archive} has been added and is ready for use!", :prefix => true
  end

  private

  def parser
    OptionParser.new do |o|
      o.banner = "Usage: vagrant pe-build copy path/to/installer.tar.gz"
      o.separator ''

      o.on('-v', '--version=val', String, "The version of PE to fetch") do |val|
        options[:version] = val
      end
    end
  end
end
