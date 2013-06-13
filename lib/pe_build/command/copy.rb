require 'vagrant'
require 'optparse'
require 'pe_build/archive'

module PEBuild
class Command
class Copy < Vagrant.plugin(2, :command)

  def execute

    options = {}

    parser = OptionParser.new do |o|
      o.banner = "Usage: vagrant pe-build copy path/to/installer.tar.gz"
      o.separator ''

      o.on('-v', '--version=val', String, "The version of PE to fetch") do |val|
        options[:version] = val
      end
    end

    argv = parse_options(parser)
    fpath = argv.last

    basename = File.basename(fpath)
    dirname  = File.dirname(fpath)

    #unless options[:version]
    #  raise Vagrant::Errors::CLIInvalidUsage, :help => parser.help.chomp
    #end

    archive = PEBuild::Archive.new(fpath, @env)
    archive.version = options[:version]
    archive.copy_from(dirname)
  end
end
end
end
