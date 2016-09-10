require 'pe_build/on_machine'

# Download PE installers to a POSIX VM
#
# @since 0.14.0
class PEBuild::Cap::StageInstaller::POSIX

  extend PEBuild::OnMachine

  # Download an installer to a remote VM
  #
  # @param uri [URI] A URI containing the download source.
  # @param dest_dir [String] The destination directory to download the
  #   installer to.
  #
  # @return [void]
  def self.stage_installer(machine, uri, dest_dir='.')
    filename = File.basename(uri.path)
    installer_dir = filename.gsub(/.tar(?:\.gz)?/, '')

    # GNU tar will attempt to guess the file format. Other versions of tar,
    # such as those shipped with Solaris, take the approach that trying to
    # interpret unknown binaries is none of their business.
    tar_flags = if filename.end_with?('.tar.gz')
      'xzf'
    else
      'xf'
    end

    unless machine.communicate.test("test -d #{dest_dir}/#{installer_dir}")
      machine.ui.info I18n.t('pebuild.cap.stage_installer.downloading_installer',
        :url => uri)

      # Download and stage the installer without using sudo, so that root
      # doesn't own the resulting directory. This allows files to be uploaded
      # later.
      on_machine(machine, "curl -fsSLk #{uri} -o #{dest_dir}/#{filename}", sudo: false)
      on_machine(machine, "tar #{tar_flags} #{dest_dir}/#{filename} -C #{dest_dir}", sudo: false)
    end
  end
end
