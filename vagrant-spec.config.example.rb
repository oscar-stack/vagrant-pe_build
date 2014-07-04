require 'pathname'
require 'vagrant-spec/acceptance'

Vagrant::Spec::Acceptance.configure do |c|
  acceptance_dir = Pathname.new File.expand_path('../acceptance', __FILE__)

  c.component_paths = [acceptance_dir.to_s]
  c.skeleton_paths = [(acceptance_dir + 'skeletons').to_s]

  c.provider 'virtualbox',
    box: (acceptance_dir + 'artifacts' + 'virtualbox.box').to_s,
    env_vars: {
      'VBOX_USER_HOME' => '{{homedir}}',
      # This folder should be filled with PE tarballs for CentOS.
      'PE_BUILD_DOWNLOAD_ROOT' => (acceptance_dir + 'artifacts' + 'pe_archives').to_s,
    }
end
