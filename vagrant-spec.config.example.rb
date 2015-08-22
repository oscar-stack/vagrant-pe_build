require 'pathname'
require 'vagrant-spec/acceptance'

require_relative 'spec/shared/helpers/webserver_context'

Vagrant::Spec::Acceptance.configure do |c|
  acceptance_dir = Pathname.new File.expand_path('../acceptance', __FILE__)

  c.component_paths = [acceptance_dir.to_s]
  c.skeleton_paths = [(acceptance_dir + 'skeletons').to_s]

  c.provider 'virtualbox',
    box: (acceptance_dir + 'artifacts' + 'virtualbox.box').to_s,
    # This folder should be filled with PE tarballs for CentOS.
    archive_path: (acceptance_dir + 'artifacts' + 'pe_archives').to_s,
    pe_latest: '2015.2.0',
    env_vars: {
      'VBOX_USER_HOME' => '{{homedir}}',
    }
end
