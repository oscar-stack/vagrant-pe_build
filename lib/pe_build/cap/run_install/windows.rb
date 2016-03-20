require 'pe_build/on_machine'
class PEBuild::Cap::RunInstall::Windows

  extend PEBuild::OnMachine

  # Run the PE installer on Windows systems
  #
  # @param installer_dir [String] A path to the PE installer.
  # @param answers [Hash[String => String}] A hash of options that will be
  #   passed to msiexec as `key=value` pairs.
  #
  # @return [void]
  def self.run_install(machine, installer_path, answers)
    install_options = answers.map{|e| e.join('=')}.join(' ')
    # Lots of PowerShell commands can handle UNIX-style paths. msiexec can't.
    installer_path = installer_path.gsub('/', '\\')

    on_machine(machine, <<-EOS)
msiexec /qn /i "#{installer_path}" #{install_options}
EOS
  end
end
