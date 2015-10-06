module PEBuild
  module Provisioner
    # Provision PE agents using simplified install
    #
    # @since 0.13.0
    class PEAgent < Vagrant.plugin('2', :provisioner)
      attr_reader :facts
      attr_reader :agent_version

      def provision
        provision_init!

        unless agent_version.nil?
          machine.ui.info I18n.t(
            'pebuild.provisioner.pe_agent.already_installed',
            :version => agent_version
          )
          return
        end

        # TODO add a provisioning method that ensures the master VM is
        # configured to serve packages for a given Agent version and
        # architecture.

        # TODO Wrap in a method that handles windows VMs (by calling pe_bootstrap).
        provision_posix_agent
      end

      private

      # Set data items that are only available at provision time
      def provision_init!
        @facts = machine.guest.capability(:pebuild_facts)
        @agent_version = facts['puppetversion']
      end

      # Execute a Vagrant shell provisioner to provision POSIX agents
      #
      # Performs a `curl | bash` installation.
      def provision_posix_agent
        shell_config = Vagrant.plugin('2').manager.provisioner_configs[:shell].new
        shell_config.privileged = true
        # TODO: Extend to allow passing agent install options.
        shell_config.inline = <<-EOS
curl -k -tlsv1 -s https://#{config.master}:8140/packages/#{config.version}/install.bash | bash
        EOS
        shell_config.finalize!

        shell_provisioner = Vagrant.plugin('2').manager.provisioners[:shell].new(machine, shell_config)
        shell_provisioner.provision
      end

    end
  end
end
