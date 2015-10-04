require_relative 'base'

# Base class for retrieving facts from POSIX
#
# @abstract Subclass and override {#os_info} and {#release_info} to implement
#   for a particular POSIX system.
#
# @since 0.13.0
class PEBuild::Cap::Facts::POSIX < PEBuild::Cap::Facts::Base

  # (see PEBuild::Cap::Facts::Base#architecture)
  #
  # This method is a concrete implementation which uses `uname -m`.
  #
  # @see PEBuild::Cap::Facts::Base#architecture
  def architecture
    sudo('uname -m')[:stdout]
  end

end
