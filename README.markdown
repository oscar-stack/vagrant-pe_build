Vagrant PE build
================

Download and install Puppet Enterprise with Vagrant.

[![Build Status](https://travis-ci.org/oscar-stack/vagrant-pe_build.svg?branch=master)](https://travis-ci.org/oscar-stack/vagrant-pe_build)

Synopsis
--------

`vagrant-pe_build` manages the downloading and installation of Puppet Enterprise
on Vagrant boxes to rapidly build a functioning Puppet environment.

Vagrantfile Settings
-------------------

### Global `config.pe_build` Settings

These settings go in the config object namespace and act as defaults in
the event multiple machines are being provisioned. These settings are
optional and can be overridden in a VM's individual provisioner config.

  * `config.pe_build.version`
    * Description: The version of Puppet Enterprise to install.
  * `config.pe_build.version_file`
    * Description: A fully-qualified URI or a path relative to `download_root`. The contents of this file will be read and used to set `version` --- overriding any value that may already be set.
  * `config.pe_build.suffix` - Suffix of the Puppet Enterprise installer to use.
    * Description: The distribution specific suffix of the Puppet Enterprise
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
  * `config.pe_build.shared_installer`
    * Description: Whether to run PE installation using installers and answers
      shared using the `/vagrant` directory. If set to `false`, resources will
      be downloaded remotely from `download_root`
      to the home directory of whichever user account Vagrant is using. Defaults to `true`.

### `pe_bootstrap` Provisioner Settings

These settings are on a per provisioner basis. They configure the individual
behaviors of each provisioner instance. All of the `config.pe_build` options
can be overridden at this point.

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
  * `answer_extras`
    * Description: An array of strings that will be appended to the answer file
      template, one string per line. This can be used to supply additional
      answers and override default answers.
    * Default: An empty array.
  * `relocate_manifests`
    * Description: Whether or not to change the PE master to use a config of
      `manifestdir=/manifests` and `modulepath=/modules`. This is meant to be
      used when the vagrant working directory manifests and modules are
      remounted on the guest.
    * Options: `true`, `false`
    * Default: `false`

### `pe_agent` Provisioner Settings

The `pe_agent` provisioner installs the Puppet Agent for PE 2015.2.0 and above
and, optionally, configures PE Master VMs to support the new agent.


**NOTE:** The `pe_agent` provisioner currently does not share any configuration
with the global `config.pe_build` settings.

  * `master_vm`
    * Description: The name of a VM in the current Vagrant environment which
      hosts the Puppet master that the agent should be connected to. When this
      is set, the `master`, `autosign` and `autopurge` settings are populated
      with default values. If the `master_vm` setting is not used, then the
      `master` setting _must_ be populated with the hostname of the
      Puppet Master.
    * Default: `nil`.
  * `autosign`
    * Description: An boolean switch which controls whether or not to sign the
      agent's certificate after installation. Requires `master_vm` to be set.
    * Options: `true`, `false`
    * Default: `true`, if `master_vm` is set.
  * `autopurge`
    * Description: An boolean switch which controls whether or not to clean the
      agent's certificate from the master and purge agent data from PuppetDB
      when the agent VM is destroyed. Requires `master_vm` to be set.
    * Options: `true`, `false`
    * Default: `true`, if `master_vm` is set.
  * `master`
    * Description: The hostname or fqdn of the puppet master. Must be specified
      if `master_vm` is not set.
    * Default: `nil`. Defaults to `vm.hostname` of the Puppet Master if
      `master_vm` is set and `master_vm` if `vm.hostname` is not set.
  * `version`
    * Description: The version number of the PE Agent to install. **NOTE:**
      Currently, agents always receive the `'current'` version installed on the master. Support for setting the version number of agents will be added in a future release. * Options: A version string, `x.y.z[-optional-stuff]`, or the string
      `'current'`.
    * Default: `'current'`.


Commands
--------

Usage Example
-------------

### Minimal PE 3.x configuration

This requires that the necessary installers have already been downloaded and
added with `vagrant pe-build copy`.

```ruby
Vagrant.configure('2') do |config|
  config.pe_build.version = '3.8.4'

  config.vm.define 'master' do |node|
    node.vm.box = 'puppetlabs/centos-7.2-64-nocm'

    node.vm.provision :pe_bootstrap do |p|
      p.role = :master
    end
  end

  config.vm.define 'agent1' do |node|
    node.vm.box = 'puppetlabs/centos-7.2-64-nocm'
    node.vm.provision :pe_bootstrap
  end
end
```


### Minimal PE 2015.x configuration

Same as above, but uses `pe_agent` to provision agent nodes instead
of `pe_bootstrap`.

```ruby
Vagrant.configure('2') do |config|
  config.pe_build.version = '2015.3.3'

  config.vm.define 'master' do |node|
    node.vm.box = 'puppetlabs/centos-7.2-64-nocm'

    node.vm.provision :pe_bootstrap do |p|
      p.role = :master
    end
  end

  config.vm.define 'agent1' do |node|
    node.vm.box = 'puppetlabs/centos-7.2-64-nocm'
    node.vm.provision :pe_agent do |p|
      p.master_vm = 'master'
    end
  end
end
```


### Specifying a download root

```ruby
Vagrant.configure('2') do |config|
  config.pe_build.version = '3.8.4'
  config.pe_build.download_root = 'http://my.pe.download.mirror/installers'

  # Alternately, a local directory can be specified
  #config.pe_build.download_root = 'file://Users/luke/Downloads'

  config.vm.define 'master' do |node|
    node.vm.box = 'puppetlabs/centos-7.2-64-nocm'

    node.vm.provision :pe_bootstrap do |p|
      p.role = :master
    end
  end

  config.vm.define 'agent1' do |node|
    node.vm.box = 'puppetlabs/centos-7.2-64-nocm'

    node.vm.provision :pe_bootstrap
  end
end
```


### Using a manual answers file

```ruby
Vagrant.configure('2') do |config|
  config.pe_build.version = '3.8.4'
  config.pe_build.download_root = 'http://my.pe.download.mirror/installers'

  # Alternately, a local directory can be specified
  #config.pe_build.download_root = 'file://Users/luke/Downloads'

  config.vm.define 'master' do |node|
    node.vm.box = 'puppetlabs/centos-7.2-64-nocm'

    node.vm.provision :pe_bootstrap do |p|
      p.role = :master
      p.answer_file = 'answers/vagrant_master.answers.txt'
    end
  end

  config.vm.define 'agent1' do |node|
    node.vm.box = 'puppetlabs/centos-7.2-64-nocm'

    node.vm.provision :pe_bootstrap
  end
end
```


### Manually setting an installer filename

```ruby
Vagrant.configure('2') do |config|
  config.pe_build.version  = '3.8.4'
  config.pe_build.filename = 'puppet-enterprise-3.8.4-el-7-x86_64.tar.gz'

  config.vm.define 'master' do |node|
    node.vm.box = 'puppetlabs/centos-7.2-64-nocm'

    node.vm.provision :pe_bootstrap do |p|
      p.role = :master
    end
  end

  config.vm.define 'agent1' do |node|
    node.vm.box = 'puppetlabs/centos-7.2-64-nocm'

    node.vm.provision :pe_bootstrap
  end
end
```


Requirements
------------

[vagranthosts]: https://github.com/oscar-stack/vagrant-hosts

Ensure VMs have a FQDN set before installing PE. The easiest way to do this is by setting the `hostname` attribute of the VM configuration.

Puppet Enterprise relies on SSL for security so you'll need to ensure that your
SSL configuration isn't borked. [vagrant-hosts][vagranthosts] is recommended to
configure VMs with semi-sane DNS.

Guest VMs need to be able to directly communicate. You'll need to ensure that
they have private network interfaces prepared.

Contact
-------

  * [Source code](https://github.com/oscar-stack/vagrant-pe_build)
  * [Issue tracker](https://github.com/oscar-stack/vagrant-pe_build/issues)

If you have questions or concerns about this module, contact finch on on
Freenode, or email adrien@puppetlabs.com.
