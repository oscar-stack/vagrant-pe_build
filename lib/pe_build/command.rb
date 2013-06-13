require 'vagrant'

module PEBuild
class Command < Vagrant.plugin(2, :command)

  def initialize(argv, env)
    super

    @main_args, @subcommand, @sub_args = split_main_and_subcommand(argv)

    @subcommands = Vagrant::Registry.new

    register_subcommands
  end

  def execute
    if @subcommand and (klass = @subcommands.get(@subcommand))
      klass.new(@argv, @env).execute
    elsif @subcommand
      raise "Unrecognized subcommand #{@subcommand}"
    else
      print_help
    end
  end

  private

  def register_subcommands
    @subcommands.register('copy') do
      require_relative 'command/copy'
      PEBuild::Command::Copy
    end

    @subcommands.register('download') do
      require_relative 'command/download'
      PEBuild::Command::Download
    end

    @subcommands.register('list') do
      require_relative 'command/list'
      PEBuild::Command::List
    end
  end

  def print_help
    cmd = 'vagrant pe-build'
    opts = OptionParser.new do |opts|
      opts.banner = "Usage: #{cmd} <command> [<args>]"
      opts.separator ""
      opts.separator "Available subcommands:"

      # Add the available subcommands as separators in order to print them
      # out as well.
      keys = []
      @subcommands.each { |key, value| keys << key.to_s }

      keys.sort.each do |key|
        opts.separator "     #{key}"
      end

      opts.separator ""
      opts.separator "For help on any individual command run `#{cmd} COMMAND -h`"
    end

    @env.ui.info(opts.help, :prefix => false)
  end
end
end
