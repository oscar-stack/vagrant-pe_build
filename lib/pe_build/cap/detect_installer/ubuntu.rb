class PEBuild::Cap::DetectInstaller::Ubuntu < PEBuild::Cap::DetectInstaller::Base

  def name
    'ubuntu'
  end

  def release_file
    '/etc/issue'
  end

  def release_file_format
    %r[Ubuntu (\d{2}\.\d{2})]
  end

  def supported_releases
    %w[10.04 12.04]
  end
end
