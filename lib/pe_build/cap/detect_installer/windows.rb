require 'pe_build/util/version_string'

# detect_installer implementation for Windows guests
#
# @abstract
# @api protected
class PEBuild::Cap::DetectInstaller::Windows < PEBuild::Cap::DetectInstaller::Base

  def detect
    # Starting with PE 3.7.0, separate 64-bit packages are shipped for Windows.
    if (PEBuild::Util::VersionString.compare(@version, '3.7.0') >= 0) && (arch == 'x64')
      "puppet-enterprise-#{@version}-x64.msi"
    else
      "puppet-enterprise-#{@version}.msi"
    end
  end

  # @since 0.13.0
  def arch
    results = execute_command('if ([System.IntPtr]::Size -eq 4) { "x86" } else { "x64" }')

    unless results[:retval] == 0
      raise PEBuild::Cap::DetectInstaller::DetectFailed,
        :name  => @machine.name,
        :error => "Could not determine Windows architecture on #{@machine.name}: got #{results[:stderr]}"
    end

    results[:stdout]
  end

end
