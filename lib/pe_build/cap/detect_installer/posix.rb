# Provide an abstract base class for detecting the installer name on
# POSIX systems.
#
# @abstract
# @protected
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
      raise "#{self.class.name} release #{dist_version} not supported"
    end

    "puppet-enterprise-#{@version}-#{name}-#{dist_version}-#{arch}.#{ext}"
  end

  def arch
    content = ""
    @machine.communicate.execute("uname -m") do |type, data|
      raise "Could not run 'uname -m' on #{@machine}: got #{data}" if type == :stderr
      content << data.chomp
    end

    content
  end

  def ext
    'tar.gz'
  end

  private

  def release_content
    content = ""

    @machine.communicate.execute("cat #{release_file}") do |type, data|
      raise "Could not read #{release_file} on #{@machine}: got #{data}" if type == :stderr
      content << data
    end

    content
  end

  def parse_release_file
    matchdata = release_content.match(release_file_format)

    if matchdata.nil? or matchdata[1].nil?
      raise "#{self.class.name} could not determine release value: content #{release_content.inspect} did not match #{release_file_format}"
    end

    matchdata[1]
  end
end
