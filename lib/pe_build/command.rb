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
      PEBuild::Command::List.new(@argv, @env).execute
    end
  end

  private

  def register_subcommands
    #@subcommands.register('copy') do
    #  require_relative 'command/copy'
    #  PEBuild::Command::Copy
    #end

    @subcommands.register('download') do
      require_relative 'command/download'
      PEBuild::Command::Download
    end

    @subcommands.register('list') do
      require_relative 'command/list'
      PEBuild::Command::List
    end
  end
end
end
