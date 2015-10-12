require_relative 'posix'

# Facts implementation for Solaris guests
#
# @since 0.13.0
class PEBuild::Cap::Facts::Solaris < PEBuild::Cap::Facts::POSIX

  # (see PEBuild::Cap::Facts::Base#os_info)
  #
  # Currently returns `family` as `Solaris`.
  #
  # @see PEBuild::Cap::Facts::Base#os_info
  def os_info
    {
      'family' => 'Solaris'
    }
  end

  # (see PEBuild::Cap::Facts::Base#release_info)
  #
  # Reads `/etc/release` and generates a `full` version along with a
  # `major` component.
  #
  # @todo Capture full version string. I.E 11.2, 10u11, etc and add `minor`
  #   component.
  #
  # @see PEBuild::Cap::Facts::Base#release_info
  def release_info
    release_file = sudo('cat /etc/release')[:stdout]

    # Cribbed from Facter 2.4.
    if match = release_file.match(/\s+s(\d+)[sx]?(_u\d+)?.*(?:SPARC|X86)/)
      version = match.captures.join('')
    elsif match = release_file.match(/Solaris ([0-9\.]+(?:\s*[0-9\.\/]+))\s*(?:SPARC|X86)/)
      version = match.captures.first
    else
      version = sudo('uname -v')[:stdout]
    end

    {
      'major' => version.scan(/\d+/).first,
      'full'  => version
    }
  end

end
