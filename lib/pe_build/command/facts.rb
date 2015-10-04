require 'json'

class PEBuild::Command::Facts < Vagrant.plugin(2, :command)

  def self.synopsis
    'Load facts from running VMs'
  end

  def execute
    argv = parse_options(parser)
    argv.shift # Remove 'facts' subcommand.

    running = @env.active_machines.map do |name, provider|
      @env.machine(name, provider)
    end.select do |vm|
      begin
        vm.communicate.ready?
      rescue Vagrant::Errors::VagrantError
        # WinRM will raise an error if the VM isn't running instead of
        # returning false (GH-6356).
        false
      end
    end

    # Filter the list of VMs for inspection down to just those passed on the
    # command line. Warn if the user passed a VM that was not running.
    unless argv.empty?
      running_vms = running.map {|vm| vm.name.to_s}
      argv.each do |name|
        @env.ui.warn I18n.t('pebuild.command.facts.vm_not_running', :vm_name => name) unless running_vms.include? name
      end

      running.select! {|vm| argv.include? vm.name.to_s}
    end

    running.each do |vm|
      facts = vm.guest.capability(:pebuild_facts)

      @env.ui.machine('guest-facts', facts, {:target => vm.name.to_s})
      @env.ui.info(JSON.pretty_generate(facts))
    end

    return 0
  end

  private

  def parser
    OptionParser.new do |o|
      o.banner = <<-BANNER
      Usage: vagrant pe-build facts [vm-name]
      BANNER

      o.separator ''

      o.on('-h', '--help', 'Display this help') do
        puts o
        exit(0)
      end
    end
  end

end
