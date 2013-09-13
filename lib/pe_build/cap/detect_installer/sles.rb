class PEBuild::Cap::DetectInstaller::Sles < PEBuild::Cap::DetectInstaller::POSIX

  def name
    'sles'
  end

  def release_file
    '/etc/SuSE-release'
  end

  def release_file_format
    %r[VERSION = (\d+)]
  end

  def supported_releases
    %w[11]
  end
end
