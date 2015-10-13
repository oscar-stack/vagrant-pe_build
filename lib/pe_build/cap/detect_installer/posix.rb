# Provide an abstract base class for detecting the installer name on
# POSIX systems.
#
# @abstract
# @api protected
class PEBuild::Cap::DetectInstaller::POSIX < PEBuild::Cap::DetectInstaller::Base

  # @!method name
  #   @abstract
  #   @return [String] The name of the distribution

  # @!method release_file
  #   @abstract
  #   @return [String] The file to use as the release file for the guest

  # @!method release_file_format
  #   @abstract
  #   @return [Regexp] A regular expression with one capture that parses the distro version

  # @!method supported_releases
  #   @abstract
  #   @return [Array<String>] All supported releases for the distribution

  def detect
    dist_version = parse_release_file

    unless supported_releases.include? dist_version
      raise PEBuild::Cap::DetectInstaller::DetectFailed,
        :name  => @machine.name,
        :error => "#{self.class.name} release #{dist_version} not supported"
    end

    "puppet-enterprise-#{@version}-#{name}-#{dist_version}-#{arch}.#{ext}"
  end

  def arch
    results = execute_command("uname -m")

    unless results[:retval] == 0
      raise PEBuild::Cap::DetectInstaller::DetectFailed,
        :name  => @machine.name,
        :error => "Could not run 'uname -m' on #{@machine.name}: got #{results[:stderr]}"
    end

    content = results[:stdout]

    content = 'i386' if content.match /i\d86/

    content
  end

  def ext
    # Posix release versions of Puppet Enterprise are packaged as .tar.gz
    # files. Pre-release builds are not gzip'd. Select a default extension
    # accordingly. As usual, for exceptional circumstances it's always possible
    # to specify an explicit filename rather than relying on the
    # detect_installer capability.
    if @version =~ /^\d+\.\d+\.\d+$/
      'tar.gz'
    else
      'tar'
    end
  end

  private

  def release_content
    results = execute_command("cat #{release_file}")

    unless results[:retval] == 0
      raise PEBuild::Cap::DetectInstaller::DetectFailed,
        :name  => @machine.name,
        :error => "Could not read #{release_file} on #{@machine.name}: got #{results[:stderr]}"
    end

    results[:stdout]
  end

  def parse_release_file
    matchdata = release_content.match(release_file_format)

    if matchdata.nil? or matchdata[1].nil?
      raise PEBuild::Cap::DetectInstaller::DetectFailed,
        :name  => @machine.name,
        :error => "#{self.class.name} could not determine release value: content #{release_content.inspect} did not match #{release_file_format}"
    end

    matchdata[1]
  end
end
