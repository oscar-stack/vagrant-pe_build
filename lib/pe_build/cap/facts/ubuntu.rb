require_relative 'posix'

# Facts implementation for Ubuntu guests
#
# @since 0.13.0
class PEBuild::Cap::Facts::Ubuntu < PEBuild::Cap::Facts::POSIX

  # (see PEBuild::Cap::Facts::Base#os_info)
  #
  # Returns `family` as `Debian` and `name` as `Ubuntu`.
  #
  # @see PEBuild::Cap::Facts::Base#os_info
  def os_info
    {
      'name'   => 'Ubuntu',
      'family' => 'Debian'
    }
  end


  # (see PEBuild::Cap::Facts::Base#release_info)
  #
  # Reads `/etc/issue` and generates a `full` version.
  #
  # @see PEBuild::Cap::Facts::Base#release_info
  def release_info
    release_file = sudo('cat /etc/issue')[:stdout]
    version = release_file.match(/Ubuntu (\d{2}\.\d{2})/)[1]

    {
      'full'  => version
    }
  end

end
