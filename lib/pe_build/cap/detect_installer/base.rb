class PEBuild::Cap::DetectInstaller::Base

  def self.detect_installer(machine, version)
    new(machine, version).detect
  end

  def initialize(machine, version)
    @machine, @version = machine, version
  end

  # @!method detect
  #   Return the installer for the given operating system
  #   @abstract
  #   @return [String] The installer for the given operating system

  private

  # TODO: Consolidate with implementation in Cap::Facts::Base.
  def execute_command(cmd)
    stdout = ''
    stderr = ''

    retval = @machine.communicate.execute(cmd, :error_check => false) do |type, data|
      if type == :stderr
        stderr << data
      else
        stdout << data
      end
    end

    {:stdout => stdout.chomp, :stderr => stderr.chomp, :retval => retval}
  end
end
