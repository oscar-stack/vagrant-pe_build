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

  * `config.pe_build.version`
    * Description: The version of Puppet Enterprise to install.
  * `config.pe_build.suffix` - Suffix of the Puppet Enterprise installer to use.
    * Description: The distribution specifix suffix of the Puppet Enterprise
      installer to use.
    * Default: `:detect`
  * `config.pe_build.filename`
    * Description: The filename of the Puppet Enterprise installer.
    * Default: this will use the version and suffix provided to guess a filename
      of the form `puppet-enterprise-<version>-<suffix>.tar.gz`.
  * `config.pe_build.download_root`
    * Description: The URI to the directory containing Puppet Enterprise
      installers if the installer is not yet cached. This setting is optional.
    * Supported URI schemes:
      * http
      * https
      * ftp
      * file
      * A blank URI will default to `file`.

#### Provisioner Namespace

These settings are on a per provisioner basis. They configure the individual
behaviors of the provisioner. All of the `config.pe_build` options can be
overridden at this point.

  * `role`
    * Description: The role of the Puppet Enterprise install.
    * Options: `:agent`, `:master`
    * Default: `:agent`
  * `verbose`
    * Description: Whether or not to show the verbose output of the Puppet
      Enterprise install.
    * Options: `true`, `false`
    * Default: `true`
  * `master`
    * Description: The address of the puppet master
    * Default: `master`
  * `answer_file`
    * Description: The location of alternate answer file for PE installation.
      Values can be paths relative to the Vagrantfile's project directory.
    * Default: The default answer file for the Puppet Enterprise version and
      role.
  * `relocate_manifests`
    * Description: Whether or not to change the PE master to use a config of
      `manifestdir=/manifests` and `modulepath=/modules`. This is meant to be
      used when the vagrant working directory manifests and modules are
      remounted on the guest.
    * Options: `true`, `false`
    * Default: `false`

Commands
--------

Usage Example
-------------

### Minimal configuration

This requires that the necessary installers have already been downloaded and
added with `vagrant pe-build copy`.

    Vagrant.configure('2') do |config|
      config.pe_build.version = '3.0.0'

      config.vm.define 'master' do |node|
        node.vm.box = 'centos-6-i386'

        node.vm.provision :pe_bootstrap do |provisioner|
          provisioner.role = :master
        end
      end

      config.vm.define 'agent1' do |node|
        node.vm.box = 'centos-6-i386'
        node.vm.provision :pe_bootstrap
        end
      end
    end

### Specifying a download root

    Vagrant.configure('2') do |config|
      config.pe_build.version = '3.0.0'
      config.pe_build.download_root = 'http://my.pe.download.mirror/installers'

      # Alternately, a local directory can be specified
      #config.pe_build.download_root = 'file://Users/luke/Downloads'

      config.vm.define 'master' do |node|
        node.vm.box = 'centos-6-i386'

        node.vm.provision :pe_bootstrap do |provisioner|
          provisioner.role = :master
        end
      end

      config.vm.define 'agent1' do |node|
        node.vm.box = 'centos-6-i386'

        node.vm.provision :pe_bootstrap
      end
    end

### Using a manual answers file

    Vagrant.configure('2') do |config|
      config.pe_build.version = '3.0.0'
      config.pe_build.download_root = 'http://my.pe.download.mirror/installers'

      # Alternately, a local directory can be specified
      #config.pe_build.download_root = 'file://Users/luke/Downloads'

      config.vm.define 'master' do |node|
        node.vm.box = 'centos-6-i386'

        node.vm.provision :pe_bootstrap do |provisioner|
          provisioner.role = :master
          provisioner.answer_file = 'answers/vagrant_master.answers.txt'
        end
      end

      config.vm.define 'agent1' do |node|
        node.vm.box = 'centos-6-i386'

        node.vm.provision :pe_bootstrap
      end
    end

### Manually setting a filename

    Vagrant.configure('2') do |config|
      config.pe_build.version  = '3.0.0'
      config.pe_build.filename = 'puppet-enterprise-3.0.0-all.tar.gz'

      # Alternately, a local directory can be specified
      #config.pe_build.download_root = 'file://Users/luke/Downloads'

      config.vm.define 'master' do |node|
        node.vm.box = 'centos-6-i386'

        node.vm.provision :pe_bootstrap do |provisioner|
          provisioner.role = :master
          provisioner.answer_file = 'answers/vagrant_master.answers.txt'
        end
      end

      config.vm.define 'agent1' do |node|
        node.vm.box = 'centos-6-i386'

        node.vm.provision :pe_bootstrap
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
