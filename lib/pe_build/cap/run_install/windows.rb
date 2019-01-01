require 'pe_build/on_machine'
class PEBuild::Cap::RunInstall::Windows

  extend PEBuild::OnMachine

  # Run the PE installer on Windows systems
  #
  # @param machine [Vagrant::Machine] The Vagrant machine on which to run the
  #   installation.
  # @param installer_dir [String] A path to the PE installer.
  # @param answers [Hash[String => String}] A hash of options that will be
  #   passed to msiexec as `key=value` pairs.
  #
  # @param options [Hash] Additional options that influence installer behavior.
  #
  # @return [void]
  def self.run_install(machine, installer_path, answers, **options)
    install_options = answers.map{|e| e.join('=')}.join(' ')
    # Lots of PowerShell commands can handle UNIX-style paths. msiexec can't.
    installer_path = installer_path.gsub('/', '\\')

    cmd = <<-EOS
$WorkingDirectory = (Get-Item -Path "#{installer_path}" -ErrorVariable InstallerMissing).Directory.FullName
If ($InstallerMissing) { Exit 1 }

$Package = (Get-Item -Path "#{installer_path}").FullName
$LogFile = "${WorkingDirectory}\\puppet-enterprise-installer.log"

$params = @(
  "/qn",
  "/i `"${Package}`"",
  "/l*v `"${LogFile}`"",
  "#{install_options}"
)

Write-Host "Running msiexec to install: ${Package}"

$Result = (Start-Process -FilePath "msiexec.exe" -ArgumentList $params -Wait -Passthru).ExitCode

If ($Result -ne 0) {
  $HOST.UI.WriteErrorLine("msiexec failed with exitcode: ${Result}")
  $HOST.UI.WriteErrorLine("Contents of ${LogFile}:")
  Get-Content "${LogFile}" | ForEach-Object { $HOST.UI.WriteErrorLine($_) }
} Else {
  Write-Host "msiexec completed with exitcode: ${Result}"
}

Exit $Result
EOS

    on_machine(machine, cmd)
  end
end
