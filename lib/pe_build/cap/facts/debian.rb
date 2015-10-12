require_relative 'posix'

# Facts implementation for Debian guests
#
# @since 0.13.0
class PEBuild::Cap::Facts::Debian < PEBuild::Cap::Facts::POSIX

  # (see PEBuild::Cap::Facts::Base#os_info)
  #
  # Returns `family` as `Debian` and `name` as `Debian`.
  #
  # @see PEBuild::Cap::Facts::Base#os_info
  def os_info
    {
      'name'   => 'Debian',
      'family' => 'Debian'
    }
  end

  # (see PEBuild::Cap::Facts::Base#release_info)
  #
  # Reads `/etc/debian_version` and generates a `full` version along with
  # `major` and `minor` components.
  #
  # @see PEBuild::Cap::Facts::Base#release_info
  def release_info
    release_file = sudo('cat /etc/debian_version')[:stdout]
    version = release_file.match(/(\d+\.\d+)/)[1]

    {
      'major' => version.split('.', 2)[0],
      'minor' => version.split('.', 2)[1],
      'full'  => version
    }
  end

end
