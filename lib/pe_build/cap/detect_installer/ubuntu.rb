class PEBuild::Cap::DetectInstaller::Ubuntu < PEBuild::Cap::DetectInstaller::POSIX

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
    %w[10.04 12.04 14.04 15.04 15.10 16.04 18.04]
  end

  def arch
    retval = super
    (retval == 'x86_64') ? 'amd64' : retval
  end
end
