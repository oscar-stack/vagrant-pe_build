require 'pe_build/on_machine'
require 'pe_build/util/version_string'

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

      resources << gen_relocate if @config.relocate_manifests
      resources << gen_autosign if @config.autosign
      resources << gen_service

      manifest = resources.join("\n\n")
      write_manifest(manifest)

      if PEBuild::Util::VersionString.compare(@config.version, '4.0.0') < 0 then
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
        notify  => Service['pe-httpd'],
      }

      # Update puppet.conf to add the modulepath directive to point to the
      # /module mount, if it hasn't already been set.
      augeas { 'move_modulepath':
        changes => 'set etc/puppetlabs/puppet/puppet.conf/main/modulepath /modules',
        notify  => Service['pe-httpd'],
      }

      # Rewrite the olde site.pp config since it's not used, and warn people
      # about this.
      file { 'old_site.pp':
        ensure  => file,
        path    => '/etc/puppetlabs/puppet/manifests/site.pp',
        content => '# /etc/puppetlabs/puppet/manifests is not used; see /manifests.',
        notify  => Service['pe-httpd'],
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
        notify  => Service['pe-httpd'],
      }
    MANIFEST

    manifest
  end

  def gen_service
    manifest = <<-MANIFEST.gsub(/^\s{6}/, '')
      service { 'pe-httpd':
        ensure => running,
      }
    MANIFEST

    manifest
  end
end
