require 'json'

# Base class for retrieving facts from guest VMs
#
# This class implements a Guest Capability for Fact retrieval. Facter will be
# queried, if installed. Otherwise, a minimal set of base facts will be
# returned by {#basic_facts}.
#
# @abstract Subclass and override {#architecture}, {#os_info} and
#   {#release_info} to implement for a particular guest operating system.
#
# @since 0.13.0
class PEBuild::Cap::Facts::Base

  # Retrieve facts from a guest VM
  #
  # See {#load_facts} for implementation details.
  #
  # @return [Hash] A hash of facts.
  def self.pebuild_facts(machine)
    new(machine).load_facts
  end

  attr_reader :machine

  def initialize(machine)
    @machine = machine
  end

  # Load Facts from the guest VM
  #
  # @return [Hash] A hash of facts from Facter, if installed.
  # @return [Hash] A hash containing the results of {#basic_facts} if
  #   Facter is not installed.
  def load_facts
    # TODO: Facter might be located in several places that aren't on the
    # default PATH. Fix that.
    if machine.communicate.test('facter --version')
      facts = JSON.load(sudo('facter --json')[:stdout])
    else
      # Facter isn't installed yet, so we gather a minimal set of info.
      facts = basic_facts
    end

    # JSON.load can do funny things. Sort by top-level key.
    Hash[facts.sort]
  end

  # Determine basic info about a guest
  #
  # This function returns a minimal set of basic facts which should be
  # sufficient to determine what software to install on the guest.
  #
  # @return [Hash] A hash containing the `architecture` and `os` facts.
  def basic_facts
    {
      'architecture' => architecture,
      'os' => {
        'release' => release_info
      }.update(os_info)
    }
  end

  # Returns the native architecture of the OS
  #
  # @return [String] An architecture, such as `i386` or `x86_64`.
  def architecture
    raise NotImplementedError
  end

  # Returns info about the OS type
  #
  # @return [Hash] A hash containing the `family` of the operating system and,
  #   optionally, the `name`.
  def os_info
    raise NotImplementedError
  end

  # Returns info about the OS version
  #
  # @return [Hash] A hash containing the `full` version strying of the
  #   operating system and, optionally, the `minor` and `major`
  #   release versions.
  def release_info
    raise NotImplementedError
  end

  private

  def sudo(cmd)
    stdout = ''
    stderr = ''

    retval = machine.communicate.sudo(cmd) do |type, data|
      if type == :stderr
        stderr << data.chomp
      else
        stdout << data.chomp
      end
    end

    {:stdout => stdout, :stderr => stderr, :retval => retval}
  end

end
