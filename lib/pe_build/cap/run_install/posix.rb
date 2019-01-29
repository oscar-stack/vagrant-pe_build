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
  #
  # @param options [Hash] Additional options that influence installer behavior.
  # @option options [Boolean] :use_pem A flag which controls whether the PEM
  #   installer introduced in 2016.2 should be used.
  # @option options [Boolean] :update_gpg A flag which controls whether the
  #   GPG key shipped with th
  #   installer introduced in 2016.2 should be used.
  #
  # @return [void]
  def self.run_install(machine, installer_path, answers, **options)
    if options.fetch(:use_pem, false)
      on_machine(machine, "DISABLE_ANALYTICS=1 #{installer_path}/puppet-enterprise-installer -c #{answers}")
    else
      on_machine(machine, "#{installer_path}/puppet-enterprise-installer -a #{answers}")
    end

    # Update GPG key used by pe_repo.
    if options.fetch(:update_gpg, false)
      machine.ui.info I18n.t('pebuild.cap.run_install.updating_pe_repo_gpg_key')
      on_machine(machine, <<-EOS)
if [ -e #{installer_path}/gpg/GPG-KEY-puppetlabs ]; then
  if [ -e /opt/puppetlabs/puppet/modules/pe_repo ]; then
    cp #{installer_path}/gpg/GPG-KEY-puppetlabs /opt/puppetlabs/puppet/modules/pe_repo/files/GPG-KEY-puppetlabs
  elif [ -e /opt/puppet/share/puppet/modules/pe_repo ]; then
    cp #{installer_path}/gpg/GPG-KEY-puppetlabs /opt/puppet/share/puppet/modules/pe_repo/files/GPG-KEY-puppetlabs
  fi
fi
EOS
    end

    if machine.communicate.test('which at')
      machine.ui.info I18n.t('pebuild.cap.run_install.scheduling_run')
      machine.communicate.sudo("echo 'PATH=/opt/puppet/bin:/opt/puppetlabs/puppet/bin:$PATH puppet agent -t --waitforcert 10' | at now '+ 1min'")
    end
  end
end
