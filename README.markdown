Vagrant PE build
================

Download and install Puppet Enterprise with Vagrant.

Synopsis
--------

`vagrant-pe_build` manages the downloading and installation of Puppet Enterprise
on Vagrant boxes to rapidly build a functioning Puppet environment.

Usage
-----

    Vagrant.configure('2') do |config|
      config.pe_build.download_root = 'http://my.pe.download.mirror/installers'
      config.pe_build.version       = '2.7.0'
      config.pe_build.filename      = 'puppet-enterprise-2.7.0-all.tar.gz'

      config.vm.define 'master' do |node|
        node.vm.provision :pe_bootstrap do |provisioner|
          provisioner.role = :master
        end
      end

      config.vm.define 'agent1' do |node|
        node.vm.provision :pe_bootstrap do |provisioner|
          provisioner.role = :agent
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

  * Source code: https://github.com/adrienthebo/vagrant-pe\_build
  * Issue tracker: https://github.com/adrienthebo/vagrant-pe\_build/issues

If you have questions or concerns about this module, contact finch on #vagrant
on Freenode, or email adrien@puppetlabs.com.
