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
      # NOTE: Ensure symlinks exist since minitar doesn't create them. This
      # call will be reverted once the PEM changes are finalized.
      on_machine(machine, <<-EOS)
pushd #{File.dirname(installer_path)} > /dev/null
if [ -d pe-manager ]
then
  pushd pe-manager > /dev/null
  ln -sf ../VERSION ../modules .
  pushd packages > /dev/null
  ln -sf ../../packages/* .
fi
EOS
      on_machine(machine, "#{installer_path} -c #{answers}")
    else
      # NOTE: Ensure symlinks exist since minitar doesn't create them. This
      # call will be reverted once the PEM changes are finalized.
      on_machine(machine, <<-EOS)
pushd #{File.dirname(installer_path)} > /dev/null
if [ -d legacy ]
then
  pushd legacy > /dev/null
  for f in $(find . -type f -empty)
  do
    ln -sf ../$f $f
  done
fi
EOS
      on_machine(machine, "#{installer_path} -a #{answers}")
    end

    if machine.communicate.test('which at')
      machine.ui.info I18n.t('pebuild.cap.run_install.scheduling_run')
      machine.communicate.sudo("echo 'PATH=/opt/puppet/bin:/opt/puppetlabs/puppet/bin:$PATH puppet agent -t --waitforcert 10' | at now '+ 1min'")
    end
  end
end
