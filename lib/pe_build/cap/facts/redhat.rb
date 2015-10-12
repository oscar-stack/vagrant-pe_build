require_relative 'posix'

# Facts implementation for RedHat guests
#
# @since 0.13.0
class PEBuild::Cap::Facts::RedHat < PEBuild::Cap::Facts::POSIX

  # (see PEBuild::Cap::Facts::Base#os_info)
  #
  # Currently returns `family` as `RedHat`.
  # @todo Implement `name` detection (RHEL, CentOS, Sci. Linux, etc.).
  #
  # @see PEBuild::Cap::Facts::Base#os_info
  def os_info
    {
      'family' => 'RedHat'
    }
  end

  # (see PEBuild::Cap::Facts::Base#release_info)
  #
  # Reads `/etc/redhat-release` and generates a `full` version along with
  # `major` and `minor` components.
  #
  # @see PEBuild::Cap::Facts::Base#release_info
  def release_info
    release_file = sudo('cat /etc/redhat-release')[:stdout]
    version = release_file.match(/release (\d+\.\d+)/)[1]

    {
      'major' => version.split('.', 2)[0],
      'minor' => version.split('.', 2)[1],
      'full'  => version
    }
  end

end
