require 'pe_build/on_machine'
class PEBuild::Cap::RunInstall::POSIX

  extend PEBuild::OnMachine

  def self.run_install(machine, config)

    root = File.join('/vagrant', PEBuild::WORK_DIR)

    cmd_path = []
    cmd_path << root

    cmd_path << "puppet-enterprise-#{config.version}-#{config.suffix}"
    cmd_path << "puppet-enterprise-installer"

    cmd     = File.join(cmd_path)
    answers = File.join(root, 'answers', "#{machine.name}.txt")

    argv = "#{cmd} -a #{answers}"

    on_machine(machine, argv)

    machine.ui.info I18n.t('pebuild.provisioner.pe_bootstrap.scheduling_run')
    machine.communicate.sudo("echo '/opt/puppet/bin/puppet agent -t' | at next minute")
  end
end
