require 'pe_build/on_machine'
class PEBuild::Cap::RunInstall::POSIX

  extend PEBuild::OnMachine

  # Run the PE installer on POSIX systems
  #
  # @param machine [Vagrant::Machine] The Vagrant machine on which to run the
  #   installation.
  # @param installer_dir [String] A path to the directory where PE installers
  #   are kept.
  # @param answers [String] A path to a file containing installation answers.
  # @option options [Boolean] A flag which controls whether the PEM installer
  #   introduced in 2016.2 should be used.
  #
  # @return [void]
  def self.run_install(machine, installer_path, answers, **options)
    if options.fetch(:use_pem, false)
      on_machine(machine, "#{installer_path} -c #{answers}")
    else
      on_machine(machine, "#{installer_path} -a #{answers}")
    end

    if machine.communicate.test('which at')
      machine.ui.info I18n.t('pebuild.cap.run_install.scheduling_run')
      machine.communicate.sudo("echo 'PATH=/opt/puppet/bin:/opt/puppetlabs/puppet/bin:$PATH puppet agent -t --waitforcert 10' | at now '+ 1min'")
    end
  end
end
