require_relative 'posix'

# Facts implementation for SUSE guests
#
# @since 0.13.0
class PEBuild::Cap::Facts::SUSE < PEBuild::Cap::Facts::POSIX

  # (see PEBuild::Cap::Facts::Base#os_info)
  #
  # Returns `family` as `SUSE` and `name` as `SLES`.
  #
  # @see PEBuild::Cap::Facts::Base#os_info
  def os_info
    {
      'name'   => 'SLES',
      'family' => 'SUSE'
    }
  end

  # (see PEBuild::Cap::Facts::Base#release_info)
  #
  # Reads `/etc/SuSE-release` and generates a `full` version along with
  # `major` and `minor` components.
  #
  # @see PEBuild::Cap::Facts::Base#release_info
  def release_info
    release_file = sudo('cat /etc/SuSE-release')[:stdout]
    major = release_file.match(/VERSION\s*=\s*(\d+)/)[1]
    minor = release_file.match(/PATCHLEVEL\s*=\s*(\d+)/)[1]

    {
      'major' => major,
      'minor' => minor,
      'full'  => [major, minor].join('.')
    }
  end

end
