require 'vagrant'
require 'optparse'
require 'pe_build/archive'

module PEBuild
class Command
class Download < Vagrant.plugin(2, :command)

  def execute

    options = {}

    parser = OptionParser.new do |o|
      o.banner = "Usage: vagrant pe_build download --version <version> --dir <dir>"
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

    archive = PEBuild::Archive.new(filename, options[:version], @env.ui)
    archive.download_from(options[:dir])
  end
end
end
end
