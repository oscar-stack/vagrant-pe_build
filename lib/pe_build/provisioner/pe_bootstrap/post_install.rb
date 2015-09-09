require 'pe_build/on_machine'
require 'pe_build/util/version_string'

# A sub-provisioner which applies post-install configuration.
#
# This is an internal provisioner which is invoked by
# `PEBuild::Provisioner::PEBootstrap`.
#
# @api private
class PEBuild::Provisioner::PEBootstrap::PostInstall

  def initialize(machine, config, work_dir)
    @machine, @config = machine, config

    @post_install_dir = Pathname.new(File.join(work_dir, 'post-install'))
    @post_install_manifest = @post_install_dir.join("#{@machine.name}.pp")
  end

  include PEBuild::OnMachine

  def run
    if needs_post_install?
      @machine.ui.info I18n.t('pebuild.provisioner.pe_bootstrap.post_install')

      resources = []

      if PEBuild::Util::VersionString.compare(@config.version, '3.7.0') < 0 then
        resources << gen_httpd
      else
        resources << gen_puppetserver
      end
      resources << gen_relocate if @config.relocate_manifests
      resources << gen_autosign if @config.autosign

      manifest = resources.join("\n\n")
      write_manifest(manifest)

      if PEBuild::Util::VersionString.compare(@config.version, '2015.2.0') < 0 then
        puppet_apply  = "/opt/puppet/bin/puppet apply"
      else
        puppet_apply  = "/opt/puppetlabs/bin/puppet apply"
      end

      manifest_path = "/vagrant/.pe_build/post-install/#{@machine.name}.pp"

      on_machine(@machine, "#{puppet_apply} #{manifest_path}")
    end
  end

  private

  def write_manifest(manifest)
    @post_install_dir.mkpath unless @post_install_dir.exist?
    @post_install_manifest.open('w') { |fh| fh.write(manifest) }
  end

  def needs_post_install?
    !!(@config.relocate_manifests or @config.autosign)
  end

  def gen_relocate
    manifest = <<-MANIFEST.gsub(/^\s{6}/, '')
      augeas { 'move_manifestdir':
        changes => 'set etc/puppetlabs/puppet/puppet.conf/main/manifestdir /manifests',
        notify  => Service[$pe_master_service],
      }

      # Update puppet.conf to add the modulepath directive to point to the
      # /module mount, if it hasn't already been set.
      augeas { 'move_modulepath':
        changes => 'set etc/puppetlabs/puppet/puppet.conf/main/modulepath /modules',
        notify  => Service[$pe_master_service],
      }

      # Rewrite the olde site.pp config since it's not used, and warn people
      # about this.
      file { 'old_site.pp':
        ensure  => file,
        path    => '/etc/puppetlabs/puppet/manifests/site.pp',
        content => '# /etc/puppetlabs/puppet/manifests is not used; see /manifests.',
        notify  => Service[$pe_master_service],
      }
    MANIFEST

    manifest
  end

  def gen_autosign

    autosign_entries = ['pe-internal-dashboard', @machine.name ]

    case @config.autosign
    when TrueClass
      autosign_entries << '*'
    when Array
      autosign_entries += @config.autosign
    end

    autosign_content = autosign_entries.map { |line| "#{line}\n" }.join

    manifest = <<-MANIFEST.gsub(/^\s{6}/, '')
      file { '/etc/puppetlabs/puppet/autosign.conf':
        ensure  => file,
        content => "#{autosign_content}",
        owner   => 'root',
        group   => 'pe-puppet',
        mode    => '0644',
        notify  => Service[$pe_master_service],
      }
    MANIFEST

    manifest
  end

  def gen_httpd
    manifest = <<-MANIFEST.gsub(/^\s{6}/, '')
      $pe_master_service = 'pe-httpd'

      service { "$pe_master_service":
        ensure => running,
      }
    MANIFEST

    manifest
  end

  def gen_puppetserver
    manifest = <<-MANIFEST.gsub(/^\s{6}/, '')
      $pe_master_service = 'pe-puppetserver'

      service { "$pe_master_service":
        ensure => running,
      }
    MANIFEST

    manifest
  end
end
