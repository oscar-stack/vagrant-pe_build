module PEBuild
  module OnMachine
    # Execute a command on a machine and log output
    #
    # This method invokes the `execute` method of the machine's communicator
    # and logs any resulting output at info level.
    #
    #
    # @param machine [Vagrant::Machine] The Vagrant machine on which to run the
    #   command.
    # @param cmd [String] The command to run.
    # @param options [Hash] Additional options to pass to the `execute` method
    #   of the communicator.
    # @option options [Boolean] :sudo A flag which controls whether the command
    #   is executed with elevated privilages. Defaults to `true`.
    #
    # @return [void]
    def on_machine(machine, cmd, **options)
      options[:sudo] = true unless options.has_key?(:sudo)

      machine.communicate.execute(cmd, options) do |type, data|
        color = (type == :stdout) ? :green : :red
        machine.ui.info(data.chomp, :color => color, :prefix => true)
      end
    end
  end
end
