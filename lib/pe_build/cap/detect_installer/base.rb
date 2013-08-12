require 'tempfile'

class PEBuild::Cap::DetectInstaller::Base

  def self.detect_installer(machine, version)
    new(machine, version).detect
  end

  def initialize(machine, version)
    @machine, @version = machine, version
  end

  def detect
    dist_version = parse_release_file

    unless supported_releases.include? dist_version
      raise "#{self.class.name} release #{dist_version} not supported"
    end

    "puppet-enterprise-#{@version}-#{name}-#{dist_version}-#{arch}.#{ext}"
  end

  def arch
    'i386'
  end

  def ext
    'tar.gz'
  end

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

  private

  def release_content
    tmpfile = Tempfile.new('pe_build-detect_installer')

    @machine.communicate.download(release_file, tmpfile.path)

    tmpfile.read
  end

  def parse_release_file
    matchdata = release_content.match(release_file_format)

    if matchdata.nil? or matchdata[1].nil?
      raise "#{self.class.name} could not determine release value: content #{release_content.inspect} did not match #{release_file_format}"
    end

    matchdata[1]
  end
end
