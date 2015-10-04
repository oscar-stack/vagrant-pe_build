require_relative 'base'

# Facts implementation for Windows guests
#
# @since 0.13.0
class PEBuild::Cap::Facts::Windows < PEBuild::Cap::Facts::Base

  # (see PEBuild::Cap::Facts::Base#architecture)
  #
  # Looks at the default pointer size for integers and returns `x86` or `x64`.
  #
  # @see PEBuild::Cap::Facts::Base#architecture
  def architecture
    sudo('if ([System.IntPtr]::Size -eq 4) { "x86" } else { "x64" }')[:stdout]
  end

  # (see PEBuild::Cap::Facts::Base#os_info)
  #
  # Currently returns `family` as `Windows`.
  #
  # @see PEBuild::Cap::Facts::Base#os_info
  def os_info
    {
      'family'  => 'Windows',
    }
  end

  # (see PEBuild::Cap::Facts::Base#release_info)
  #
  # Queries WMI and generates a `full` version.
  #
  # @see PEBuild::Cap::Facts::Base#release_info
  def release_info
    version     = sudo('(Get-WmiObject -Class Win32_OperatingSystem).Version')[:stdout]
    producttype = sudo('(Get-WmiObject -Class Win32_OperatingSystem).Producttype')[:stdout]

    # Cribbed from Facter 2.4.
    #
    # NOTE: Currently doesn't support XP/Server 2003 or Windows 10.
    name = case version
    when /^6\.3/
      producttype == 1 ? "8.1" : "2012 R2"
    when /^6\.2/
      producttype == 1 ? "8" : "2012"
    when /^6\.1/
      producttype == 1 ? "7" : "2008 R2"
    when /^6\.0/
      producttype == 1 ? "Vista" : "2008"
    else
      version # Default to the raw version number.
    end

    {
      'full' => name
    }
  end

end
