class PEBuild::Cap::DetectInstaller::Redhat < PEBuild::Cap::DetectInstaller::Base

  def name
    'el'
  end

  def release_file
    '/etc/redhat-release'
  end

  def release_file_format
    %r[release (\d+)\.\d+]
  end

  def supported_releases
    %w[5 6]
  end
end
