class PEBuild::Cap::DetectInstaller::SLES < PEBuild::Cap::DetectInstaller::POSIX

  def name
    'sles'
  end

  def release_file
    '/etc/SuSE-release'
  end

  def release_file_format
    %r[^SUSE Linux Enterprise Server (\d+)]
  end

  def supported_releases
    %w[11]
  end
end

