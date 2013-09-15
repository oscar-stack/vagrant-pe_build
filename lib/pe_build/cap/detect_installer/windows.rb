# Provide an abstract base class for detecting the installer name on
# POSIX systems.
#
# @abstract
# @protected
class PEBuild::Cap::DetectInstaller::Windows < PEBuild::Cap::DetectInstaller::Base

  # @!method supported_releases
  #   @abstract
  #   @return [Array<String>] All supported releases for the distribution

  def detect
    unless supported_releases.include? dist_version
      raise PEBuild::Cap::DetectInstaller::DetectFailed,
        :name  => @machine.name,
        :error => "#{self.class.name} release #{dist_version} not supported"
    end

    "puppet-enterprise-#{@version}.msi"
  end

  private

  def dist_version
    'not implemented'
  end

  def supported_releases
    ['not implemented']
  end

end
