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

  private

  def find_puppet
    paths = %w[
      /opt/puppetlabs/bin/puppet
      /opt/puppet/bin/puppet
      /usr/local/bin/puppet
    ]

    paths.each do |path|
      return path if @machine.communicate.test("#{path} --version")
    end

    return nil
  end

end
