class PEBuild::Cap::DetectInstaller::Debian < PEBuild::Cap::DetectInstaller::Base

  def name
    'debian'
  end

  def release_file
    '/etc/debian_version'
  end

  def release_file_format
    %r[^(\d+)\.]
  end

  def supported_releases
    %w[6 7]
  end
end
