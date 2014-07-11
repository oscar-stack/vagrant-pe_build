# Provide an abstract base class for detecting the installer name on
# POSIX systems.
#
# @abstract
# @api protected
class PEBuild::Cap::DetectInstaller::Windows < PEBuild::Cap::DetectInstaller::Base

  def detect
    # Yes, it really is this simple. For Windows anyway.
    "puppet-enterprise-#{@version}.msi"
  end

end
