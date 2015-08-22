require 'vagrant'

class PEBuild::Command::Base < Vagrant.plugin(2, :command)

  def self.synopsis
    'list and download PE installers'
  end

  def initialize(argv, env)
    super
    split_argv

    @subcommands = {
      'list'     => PEBuild::Command::List,
      'download' => PEBuild::Command::Download,
      'copy'     => PEBuild::Command::Copy,
    }
  end

  def execute
    if @subcommand
      execute_subcommand
    else
      print_help
    end
  end

  private

  def split_argv
    @main_args, @subcommand, @sub_args = split_main_and_subcommand(@argv)
  end

  def execute_subcommand
    if (klass = @subcommands[@subcommand])
      klass.new(@argv, @env).execute
    else
      raise "Unrecognized subcommand #{@subcommand}"
    end
  end

  def print_help
    cmd = 'vagrant pe-build'
    opts = OptionParser.new do |opts|
      opts.banner = "Usage: #{cmd} <command> [<args>]"
      opts.separator ""
      opts.separator "Available subcommands:"

      @subcommands.keys.sort.each do |key|
        opts.separator "     #{key}"
      end

      opts.separator ""
      opts.separator "For help on any individual command run `#{cmd} COMMAND -h`"
    end

    @env.ui.info(opts.help, :prefix => false)
  end
end
