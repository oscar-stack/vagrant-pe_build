module PEBuild
  module OnMachine
    def on_machine(machine, cmd)
      machine.communicate.sudo(cmd) do |type, data|
        color = (type == :stdout) ? :green : :red
        machine.ui.info(data.chomp, :color => color, :prefix => true)
      end
    end
  end
end
