require 'pe_build/util/pe_packaging'
require 'pe_build/util/machine_comms'

require 'vagrant/errors'

require 'uri'

module PEBuild
  module Provisioner
    # Provision PE agents using simplified install
    #
    # @since 0.13.0
    class PEAgent < Vagrant.plugin('2', :provisioner)
      include ::PEBuild::Util::PEPackaging
      include ::PEBuild::Util::MachineComms

      attr_reader :facts
      attr_reader :agent_version
      attr_reader :master_vm

      def provision
        provision_init!

        # NOTE: When enabling installation for PE 3.x, Windows isn't supported
        # by that build of pe_repo.
        unless master_vm.nil?
          provision_pe_repo
        end
        provision_agent
        provision_agent_cert if config.autosign
        provision_agent_type unless config.agent_type == 'agent'
      end

      # This gets run during agent destruction and will remove the agent's
      # certificate from the master, if requested.
      def cleanup
        # Search the list of created VMs, which is a list of [name, provider]
        # tuples. This will fail to match anything if config.master_vm is nil.
        vm_def = machine.env.active_machines.find {|vm| vm[0].to_s == config.master_vm.to_s}
        if vm_def.nil?
          machine.ui.warn I18n.t(
            'pebuild.provisioner.pe_agent.skip_purge_no_master',
            :master => config.master_vm.to_s
          )
          return
        end
        @master_vm = machine.env.machine(*vm_def)

        cleanup_agent_cert if config.autopurge
        cleanup_agent_type unless config.agent_type == 'agent'
      end

      private

      # Set data items that are only available at provision time
      def provision_init!
        @facts = machine.guest.capability(:pebuild_facts)
        @agent_version = facts['puppetversion']

        # Resolve the master_vm setting to a Vagrant machine reference.
        unless config.master_vm.nil?
          vm_def = machine.env.active_machines.find {|vm| vm[0].to_s == config.master_vm.to_s}

          unless vm_def.nil?
            @master_vm       = machine.env.machine(*vm_def)
            config.master    ||= ( @master_vm.config.vm.hostname || @master_vm.name ).to_s
          end
        end
      end

      # A quick test to determine if we are provisioning a Windows agent
      #
      # This method requires {#provision_init!} to be called.
      def provision_windows?
        facts['os']['family'].downcase == 'windows'
      end

      def provision_agent
        unless agent_version.nil?
          machine.ui.info I18n.t(
            'pebuild.provisioner.pe_agent.already_installed',
            :version => agent_version
          )
          return
        end

        if provision_windows?
          provision_windows_agent
        else
          provision_posix_agent
        end

        # Refresh agent facts post-installation.
        @facts = machine.guest.capability(:pebuild_facts)
      end

      # Ensure a master VM is able to serve agent packages
      #
      # This method inspects the master VM and ensures it is configured to
      # serve packages for the agent's architecture.
      def provision_pe_repo
        # This method will raise an error if commands can't be run on the
        # master VM.
        ensure_reachable(master_vm)

        platform         = platform_tag(facts)
        # Transform the platform_tag into a Puppet class name.
        pe_repo_platform = platform.gsub('-', '_').gsub('.', '')
        # TODO: Support PE 3.x
        platform_repo    = "/opt/puppetlabs/server/data/packages/public/current/#{platform}"

        # Print a message and return if the agent repositories exist on the
        # master.
        if master_vm.communicate.test("[ -e #{platform_repo} ]", :sudo => true)
          master_vm.ui.info I18n.t(
            'pebuild.provisioner.pe_agent.pe_repo_present',
            :vm_name      => master_vm.name,
            :platform_tag => platform
          )
          return
        end

        master_vm.ui.info I18n.t(
          'pebuild.provisioner.pe_agent.adding_pe_repo',
          :vm_name      => master_vm.name,
          :platform_tag => platform
        )

        master_version = ''
        err_code = master_vm.communicate.sudo('cat /opt/puppetlabs/server/pe_version', error_check: false) do |type, output|
                     master_version << output if type == :stdout
                   end
        master_version = '0.0' if (err_code != 0)
        platform_install_cmd = PEBuild::Util::VersionString.compare(master_version, '2019.8') < 0 ?
                    "/opt/puppetlabs/bin/puppet apply -e 'include pe_repo::platform::#{pe_repo_platform}'" :
                    "/opt/puppetlabs/bin/puppet apply -e 'class{pe_repo: enable_bulk_pluginsync => false, enable_windows_bulk_pluginsync => false };include pe_repo::platform::#{pe_repo_platform}'"
        shell_config = Vagrant.plugin('2').manager.provisioner_configs[:shell].new
        shell_config.privileged = true
        # TODO: Extend to configuring agent repos which are older than the
        # master.
        # TODO: Extend to PE 3.x masters.
        shell_config.inline = platform_install_cmd
        shell_config.finalize!

        shell_provisioner = Vagrant.plugin('2').manager.provisioners[:shell].new(master_vm, shell_config)
        shell_provisioner.provision
      end

      # Execute a Vagrant shell provisioner to provision POSIX agents
      #
      # Performs a `curl | bash` installation.
      def provision_posix_agent
        shell_config = Vagrant.plugin('2').manager.provisioner_configs[:shell].new
        shell_config.privileged = true
        # Installation is split into to components running under set -e so that
        # failures are detected. The curl command uses `sS` so that download
        # progress is silenced, but error messages are still printed.
        #
        # TODO: Extend to allow passing agent install options.
        # TODO: Extend to use `config.version` once {#provision_pe_repo}
        # supports it.
        shell_config.inline = <<-EOS
set -e
curl -ksS --tlsv1 https://#{config.master}:8140/packages/current/install.bash -o pe_frictionless_installer.sh
bash pe_frictionless_installer.sh
        EOS
        shell_config.finalize!

        machine.ui.info "Running: #{shell_config.inline}"

        shell_provisioner = Vagrant.plugin('2').manager.provisioners[:shell].new(machine, shell_config)
        shell_provisioner.provision
      end

      # Install a PE Agent on Windows
      #
      # Executes a `pe_bootstrap` provisioner running in agent mode.
      def provision_windows_agent
        platform_tag = platform_tag(facts)
        installer = "puppet-agent-#{facts['architecture']}.msi"
        # TODO: Extend to allow passing arbitrary install options.
        answers = {
          'PUPPET_MASTER_SERVER'  => config.master,
          'PUPPET_AGENT_CERTNAME' => machine.name,
        }

        # TODO: Extend to use `config.version` once {#provision_pe_repo}
        # supports it.
        installer_url = URI.parse("https://#{config.master}:8140/packages/current/#{platform_tag}/#{installer}")

        machine.guest.capability(:stage_installer, installer_url, '.')
        machine.guest.capability(:run_install, installer, answers)
      end

      def provision_agent_cert
        # This method will raise an error if commands can't be run on the
        # master VM.
        ensure_reachable(master_vm)
        master_version = ''
        err_code = master_vm.communicate.sudo('cat /opt/puppetlabs/server/pe_version', error_check: false) do |type, output|
                     master_version << output if type == :stdout
                   end
        # Check for unrecognized PE file layouts, which are assumed to be older
        # than 2019.0.
        master_version = '0.0' if (err_code != 0)

        agent_certname = facts['certname']

        # Return if the cert has already been signed. The return code is
        # inverted as `grep -q` will exit with 1 if the certificate is not
        # found.
        # TODO: Extend paths to PE 3.x masters.
        csr_check = PEBuild::Util::VersionString.compare(master_version, '2019.0') < 0 ?
            "/opt/puppetlabs/bin/puppet cert list | grep -q -F #{agent_certname}" :
            "/opt/puppetlabs/bin/puppetserver ca list | grep -q -F #{agent_certname}"
        if not master_vm.communicate.test(csr_check, :sudo => true)
          master_vm.ui.info I18n.t(
            'pebuild.provisioner.pe_agent.no_csr_pending',
            :certname => agent_certname,
            :master   => master_vm.name.to_s
          )
          return
        end

        master_vm.ui.info I18n.t(
          'pebuild.provisioner.pe_agent.signing_agent_cert',
          :certname => agent_certname,
          :master   => master_vm.name.to_s
        )

        # TODO: Extend paths to PE 3.x masters.
        # NOTE: 2019.0.0 has Cert SAN allowed by default
        sign_cert = PEBuild::Util::VersionString.compare(master_version, '2019.0') < 0 ?
            "/opt/puppetlabs/bin/puppet cert --allow-dns-alt-names sign #{agent_certname}" :
            "/opt/puppetlabs/bin/puppetserver ca sign --certname #{agent_certname}"
        shell_provision_commands(master_vm, sign_cert)

      end

      def cleanup_agent_cert
        # TODO: This isn't very flexible. But, the VM is destroyed at this
        # point, so it's the best guess we have available.
        agent_certname = (machine.config.vm.hostname || machine.name).to_s

        unless is_reachable?(master_vm)
          master_vm.ui.warn I18n.t(
            'pebuild.provisioner.pe_agent.skip_purge_master_not_reachable',
            :master => master_vm.name.to_s
          )
          return
        end

        master_version = ''
        err_code = master_vm.communicate.sudo('cat /opt/puppetlabs/server/pe_version', error_check: false) do |type, output|
                     master_version << output if type == :stdout
                   end
        # Check for unrecognized PE file layouts, which are assumed to be older
        # than 2019.0.
        master_version = '0.0' if (err_code != 0)

        # TODO: Extend paths to PE 3.x masters.
        # TODO: Find a way to query an individual certificate through puppetserver ca.
        cert_check = PEBuild::Util::VersionString.compare(master_version, '2019.0') < 0 ?
            "/opt/puppetlabs/bin/puppet cert list #{agent_certname}" :
            "/opt/puppetlabs/bin/puppetserver ca list --all| grep -q -F #{agent_certname}"
        unless master_vm.communicate.test(cert_check, :sudo => true)
          master_vm.ui.info I18n.t(
            'pebuild.provisioner.pe_agent.agent_purged',
            :certname => agent_certname,
            :master   => master_vm.name.to_s
          )
          return
        end

        master_vm.ui.info I18n.t(
          'pebuild.provisioner.pe_agent.purging_agent',
          :certname => agent_certname,
          :master   => master_vm.name.to_s
        )

        shell_config = Vagrant.plugin('2').manager.provisioner_configs[:shell].new
        shell_config.privileged = true
        # TODO: Extend to PE 3.x masters.
        shell_config.inline = <<-EOS
/opt/puppetlabs/bin/puppet node purge #{agent_certname}
        EOS
        shell_config.finalize!

        shell_provisioner = Vagrant.plugin('2').manager.provisioners[:shell].new(master_vm, shell_config)

        begin
          shell_provisioner.provision
        rescue Vagrant::Errors::VagrantError => e
          master_vm.ui.error I18n.t(
            'pebuild.provisioner.pe_agent.purge_failed',
            :certname => agent_certname,
            :master   => master_vm.name.to_s,
            :error_class => e.class,
            :message => e.message
          )
        end
      end

      # Run shell provision commands on a target machine
      # commands is expected to be an array
      def shell_provision_commands(target_machine, commands)

        shell_config = Vagrant.plugin('2').manager.provisioner_configs[:shell].new
        shell_config.privileged = true
        shell_config.inline = [commands].flatten.join("\n")
        shell_config.finalize!

        target_machine.ui.info "Running: #{shell_config.inline}"

        shell_provisioner = Vagrant.plugin('2').manager.provisioners[:shell].new(target_machine, shell_config)
        shell_provisioner.provision

      end

      # Run commands on the master_vm based on the agent_type
      # Allows for provisioning replcas and compile masters
      def provision_agent_type
        ensure_reachable(master_vm)

        agent_certname = facts['certname']

        # Return if the certname is in the infrastructure status
        if master_vm.communicate.test("/opt/puppetlabs/bin/puppet infrastructure status --host #{agent_certname} --verbose | grep -q -F #{agent_certname}", :sudo => true)
          master_vm.ui.info I18n.t(
            'pebuild.provisioner.pe_agent.agent_type_provisioned',
            :certname => agent_certname,
            :master   => master_vm.name.to_s,
            :type     => config.agent_type
          )
          return
        end

        case config.agent_type
          when 'replica'
            provision_replica
          when 'compile'
            provision_compile
          else
            machine.ui.error I18n.t(
              'pebuild.provisioner.pe_agent.agent_type_invalid',
              :type => config.agent_type
            )
            return
          end
      end

      def provision_replica
        # Provision an HA replica
        agent_certname = facts['certname']

        # Check for code manager and run the puppet agent on the master if it is not running.
        unless master_vm.communicate.test("/opt/puppetlabs/bin/puppet infrastructure status --verbose | grep -q -F 'Code Manager'", :sudo => true)
          shell_provision_commands(master_vm, ['/opt/puppetlabs/bin/puppet agent -t || true', '/opt/puppetlabs/bin/puppet agent -t || true'])

          # Try to check for code manager again
          unless master_vm.communicate.test("/opt/puppetlabs/bin/puppet infrastructure status --verbose | grep -q -F 'Code Manager'", :sudo => true)
            master_vm.ui.error I18n.t(
              'pebuild.provisioner.pe_agent.code_manager_not_running',
              :certname => agent_certname,
              :master   => master_vm.name.to_s,
              :type     => config.agent_type
            )
            return
          end
        end

        master_vm.ui.info I18n.t(
          'pebuild.provisioner.pe_agent.provisioning_type',
          :certname => agent_certname,
          :master   => master_vm.name.to_s,
          :type     => config.agent_type
        )

        # Run the agent on the machine to ensure it is configured, has a report in puppetdb, and pxp-agent is running
        shell_provision_commands(machine, '/opt/puppetlabs/bin/puppet agent -t || true')

        # Install an RBAC token
        # Deploy code to ensure it has been done
        # Provision the replica
        shell_provision_commands(master_vm, ['set -e',
                                             'echo "puppetlabs" | /opt/puppetlabs/bin/puppet access login --username admin -l 0',
                                             '/opt/puppetlabs/bin/puppet code deploy --all --wait',
                                             "/opt/puppetlabs/bin/puppet infrastructure provision replica #{agent_certname}",
                                             "/opt/puppetlabs/bin/puppet infrastructure enable replica --yes --topology mono #{agent_certname}"
                                             ])
      end

      def provision_compile
        # Provision a compile master
        agent_certname = facts['certname']

        master_vm.ui.info I18n.t(
          'pebuild.provisioner.pe_agent.provisioning_type',
          :certname => agent_certname,
          :master   => master_vm.name.to_s,
          :type     => config.agent_type
        )

        # Pin the node to the PE Master group
        shell_provision_commands(master_vm, ['set -e',
                                             "CLASSIFIER=$(grep server /etc/puppetlabs/puppet/classifier.yaml | grep -Eo '([^ ]+)$')",
                                             "CERT_ARGS=\"--cert $(/opt/puppetlabs/bin/puppet config print hostcert)\
                                               --key $(/opt/puppetlabs/bin/puppet config print hostprivkey)\
                                               --cacert $(/opt/puppetlabs/bin/puppet config print localcacert)\"",
                                             "PARSE_ID_RUBY=\"require 'json'; puts JSON.parse(ARGF.read).find{ |group| group['name'] == 'PE Master' }['id']\"",
                                             "ID=$(curl -sS -k $CERT_ARGS https://$CLASSIFIER:4433/classifier-api/v1/groups |\
                                               /opt/puppetlabs/puppet/bin/ruby -e \"${PARSE_ID_RUBY}\")",
                                             "curl -sS -X POST -H 'Content-Type: application/json' $CERT_ARGS \
                                               https://$CLASSIFIER:4433/classifier-api/v1/groups/$ID/pin?nodes=#{agent_certname}"
                                             ])
        # Run the agent on the new CM
        shell_provision_commands(machine, '/opt/puppetlabs/bin/puppet agent -t || true')
        # Run the agent on the MoM to update the configuration
        shell_provision_commands(master_vm, '/opt/puppetlabs/bin/puppet agent -t || true')
      end

      # Remove agent_type configuration from master_vm
      def cleanup_agent_type
        agent_certname = (machine.config.vm.hostname || machine.name).to_s

        unless is_reachable?(master_vm)
          master_vm.ui.warn I18n.t(
            'pebuild.provisioner.pe_agent.skip_purge_master_not_reachable',
            :master => master_vm.name.to_s
          )
          return
        end

        unless master_vm.communicate.test("/opt/puppetlabs/bin/puppet infrastructure status --host #{agent_certname} --verbose | grep -q -F #{agent_certname}", :sudo => true)
          return
        end

        master_commands = []
        machine_commands = []
        # Setup a shell_provisioner
        case config.agent_type
          when 'replica'
            # Stop the PE services on the replica
            ['puppet', 'pxp-agent' 'pe-puppetserver', 'pe-puppetdb',
             'pe-orchestration-services', 'pe-console-services', 'pe-postgresql'].each do | service |
                machine_commands.push("/opt/puppetlabs/bin/puppet resource service #{service} ensure=stopped")
            end

            # Change directories to /tmp to avoid permissions errors with forget command
            # Forget the replica on the master
            master_commands.push('cd /tmp', "/opt/puppetlabs/bin/puppet infrastructure forget #{agent_certname}")

          when 'compile'
            # Unpin the node from PE Master
            master_commands.push('set -e',
                                 "CLASSIFIER=$(grep server /etc/puppetlabs/puppet/classifier.yaml | grep -Eo '([^ ]+)$')",
                                 "CERT_ARGS=\"--cert $(/opt/puppetlabs/bin/puppet config print hostcert)\
                                   --key $(/opt/puppetlabs/bin/puppet config print hostprivkey) \
                                   --cacert $(/opt/puppetlabs/bin/puppet config print localcacert)\"",
                                 "PARSE_ID_RUBY=\"require 'json'; puts JSON.parse(ARGF.read).find{ |group| group['name'] == 'PE Master' }['id']\"",
                                 "ID=$(curl -sS -k $CERT_ARGS https://$CLASSIFIER:4433/classifier-api/v1/groups | \
                                   /opt/puppetlabs/puppet/bin/ruby -e \"${PARSE_ID_RUBY}\")",
                                 "curl -sS -X POST -H 'Content-Type: application/json' $CERT_ARGS \
                                   https://$CLASSIFIER:4433/classifier-api/v1/groups/$ID/unpin?nodes=#{agent_certname}"
                                 )
          else
            return
        end

         master_vm.ui.info I18n.t(
           'pebuild.provisioner.pe_agent.cleaning_type',
           :certname => agent_certname,
           :master   => master_vm.name.to_s,
           :type     => config.agent_type
         )

        # Run the shell provisioner
        begin
          shell_provision_commands(machine, machine_commands)
          shell_provision_commands(master_vm, master_commands)
        rescue Vagrant::Errors::VagrantError => e
          master_vm.ui.error I18n.t(
            'pebuild.provisioner.pe_agent.type_cleanup_failed',
            :certname => agent_certname,
            :master   => master_vm.name.to_s,
            :error_class => e.class,
            :message => e.message,
            :type    => config.agent_type
          )
        end
      end

    end
  end
end
