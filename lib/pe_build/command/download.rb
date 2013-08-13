require 'pe_build/archive'

class PEBuild::Command::Download < Vagrant.plugin(2, :command)

  def execute

    options = {}

    parser = OptionParser.new do |o|
      o.banner = "Usage: vagrant pe-build download --version <version> --dir <dir>"
      o.separator ''

      o.on('-v', '--version=val', String, "The version of PE to fetch") do |val|
        options[:version] = val
      end

      o.on('-d', '--dir=val', String, 'The URL basedir containing the file') do |val|
        options[:dir] = val
      end
    end

    argv = parse_options(parser)
    filename = argv.last

    unless options[:version]
      raise Vagrant::Errors::CLIInvalidUsage, :help => parser.help.chomp
    end

    uri = URI.parse(options[:dir])

    archive = PEBuild::Archive.new(filename, @env)
    archive.version = options[:version]
    archive.fetch(options[:dir])
  end
end
