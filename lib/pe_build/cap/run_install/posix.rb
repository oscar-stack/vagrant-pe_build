require 'pe_build/on_machine'
class PEBuild::Cap::RunInstall::POSIX

  extend PEBuild::OnMachine

  def self.run_install(machine, config, archive)

    if machine.communicate.test('test -f /opt/puppet/pe_version')
      machine.ui.warn I18n.t('pebuild.cap.run_install.posix.already_installed'),
                      :name  => machine.name
      return
    end

    root = File.join('/vagrant', PEBuild::WORK_DIR)

    cmd_path = []
    cmd_path << root

    cmd_path << archive.installer_dir
    cmd_path << "puppet-enterprise-installer"

    cmd     = File.join(cmd_path)
    answers = File.join(root, 'answers', "#{machine.name}.txt")

    argv = "#{cmd} -a #{answers}"

    on_machine(machine, argv)


    if machine.communicate.test('which at')
      machine.ui.info I18n.t('pebuild.cap.run_install.posix.scheduling_run')
      machine.communicate.sudo("echo '/opt/puppet/bin/puppet agent -t --waitforcert 10' | at next minute")
    end
  end
end
