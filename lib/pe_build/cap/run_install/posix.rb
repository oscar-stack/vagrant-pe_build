require 'pe_build/on_machine'
class PEBuild::Cap::RunInstall::POSIX

  extend PEBuild::OnMachine

  # Run the PE installer on POSIX systems
  #
  # @param installer_dir [String] A path to the directory where PE installers
  #   are kept.
  # @param answers [String] A path to a file containing installation answers.
  #
  # @return [void]
  def self.run_install(machine, installer_path, answers)
    on_machine(machine, "#{installer_path} -a #{answers}")

    if machine.communicate.test('which at')
      machine.ui.info I18n.t('pebuild.cap.run_install.scheduling_run')
      machine.communicate.sudo("echo 'PATH=/opt/puppet/bin:/opt/puppetlabs/puppet/bin:$PATH puppet agent -t --waitforcert 10' | at now '+ 1min'")
    end
  end
end
