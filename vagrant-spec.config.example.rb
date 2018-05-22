$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

# Prevent tests from attempting to load plugins from a Vagrant install
# that may exist on the host system. We load required plugins below.
ENV['VAGRANT_DISABLE_PLUGIN_INIT'] = '1'

require 'pathname'
require 'vagrant-spec/acceptance'
require 'vagrant-pe_build'

require_relative 'spec/shared/helpers/webserver_context'

Vagrant::Spec::Acceptance.configure do |c|
  acceptance_dir = Pathname.new File.expand_path('../acceptance', __FILE__)

  c.component_paths = [acceptance_dir.to_s]
  c.skeleton_paths = [(acceptance_dir + 'skeletons').to_s]

  c.provider 'virtualbox',
    boxes: Dir[acceptance_dir + 'artifacts' + '*-virtualbox.box'],
    # This folder should be filled with PE tarballs for CentOS.
    archive_path: (acceptance_dir + 'artifacts' + 'pe_archives').to_s,
    pe_latest: '2018.1.0',
    env_vars: {
      'VBOX_USER_HOME' => '{{homedir}}',
    }
end
