require 'pe_build/on_machine'

# Download PE installers to a Windows VM
#
# @since 0.14.0
class PEBuild::Cap::StageInstaller::Windows

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

    unless machine.communicate.test(%Q[If (Test-Path "#{dest_dir}/#{filename}) { Exit 0 } Else { Exit 1 }])
      machine.ui.info I18n.t('pebuild.cap.stage_installer.downloading_installer',
        :url => uri)

      # Setting ServerCertificateValidationCallback to always return true
      # allows us to download from HTTPS sources that present a self-signed
      # certificate. For example, a Puppet Master.
      on_machine(machine, <<-EOS)
$DestDir = (Get-Item -Path "#{dest_dir}").FullName
Write-Host "Downloading #{filename} to: ${DestDir}"
[System.Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
(New-Object System.Net.WebClient).DownloadFile("#{uri}","$DestDir/#{filename}")
EOS
    end
  end
end
