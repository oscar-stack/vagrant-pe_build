Vagrant PE build
================

Download and install Puppet Enterprise with Vagrant.

Synopsis
--------

`vagrant-pe_build` manages the downloading and installation of Puppet Enterprise
on Vagrant boxes to rapidly build a functioning Puppet environment.

Vagrantfile Settings
-------------------

#### Config Namespace `config.pe_build`
These settings go in the config object namespace and act as defaults in
the event multiple machines are being provisioned. These settings are
optional and can be overridden in a VM's individual provisioner config.

* ```config.pe_build.version``` - Version of Puppet Enterprise to install.
* ```config.pe_build.suffix``` - Suffix of the Puppet Enterprise installer to use. Defaults to 'All'.
* ```config.pe_build.filename``` - Filename of the Puppet Enterprise installer. If unset, this option will use the version and suffix provided to guess a filename. Default takes form of
  'puppet-enterprise-<version>-<suffix>.tar.gz'.
* ```config.pe_build.download_root``` - Link to download installer from if the installer is not yet cached. This setting is optional.

#### Provisioner Namespace
These settings are on a per provisioner basis. They configure the
individual behaviors of the provisioner. Additionally, the
`config.pe_build` options are available to be overridden at this point.

* ```role``` - Role of the Puppet Enterprise install. Options are `:agent` and `:master`. Default value is `:agent`
* ```verbose``` - Whether or not to show the verbose output of the Puppet Enterprise install. Options are `true` and `false`. Default value is `true`
* ```master``` - Specify the address of the puppet master. Default value is `master`
* ```answer_file``` - Location of alternate answer file for PE installation. Values can be paths relative to the Vagrantfile's project directory. By default, PE_Build uses an internal answerfile.
* ```relocate_manifests``` - Whether or not to change the PE master's config to look in `/manifests` and `/modules` if these paths are being synced from the host. Defaults to `false`

Usage Example
-------------

    Vagrant.configure('2') do |config|
      config.pe_build.download_root = 'http://my.pe.download.mirror/installers'
      config.pe_build.version       = '2.7.0'
      config.pe_build.filename      = 'puppet-enterprise-2.7.0-all.tar.gz'

      config.vm.define 'master' do |node|
        node.vm.provision :pe_bootstrap do |provisioner|
          provisioner.role = :master
          provisioner.verbose = false
          provisioner.answer_file = 'answers/vagrant_master.answers.txt'
        end
      end

      config.vm.define 'agent1' do |node|
        node.vm.provision :pe_bootstrap do |provisioner|
          provisioner.role = :agent
          provisioner.master = 'pemaster.example.lan'
        end
      end
    end

Requirements
------------

[vagranthosts]: https://github.com/adrienthebo/vagrant-hosts

Puppet Enterprise relies on SSL for security so you'll need to ensure that your
SSL configuration isn't borked. [vagrant-hosts][vagranthosts] is recommended to
configure VMs with semi-sane DNS.

Guest VMs need to be able to directly communicate. You'll need to ensure that
they have private network interfaces prepared.

Contact
-------

  * [Source code](https://github.com/adrienthebo/vagrant-pe_build)
  * [Issue tracker](https://github.com/adrienthebo/vagrant-pe_build/issues)

If you have questions or concerns about this module, contact finch on on
Freenode, or email adrien@puppetlabs.com.
