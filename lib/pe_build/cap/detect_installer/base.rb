require 'tempfile'

class PEBuild::Cap::DetectInstaller::Base

  def self.detect_installer(machine)
    new(machine).detect
  end

  def initialize(machine)
    @machine = machine
  end

  def release_content
    tmpfile = Tempfile.new('pe_build-detect_installer')

    @machine.communicate.download(release_file, tmpfile.path)

    tmpfile.open { |fh| content = fh.read }

    content
  end

  def installer_name(distname)
    "puppet-enterprise-:version-#{distname}.tar.gz"
  end
end
