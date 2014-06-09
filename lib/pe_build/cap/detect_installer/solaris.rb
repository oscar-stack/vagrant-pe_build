class PEBuild::Cap::DetectInstaller::Solaris < PEBuild::Cap::DetectInstaller::POSIX

  def name
    'solaris'
  end

  def release_file
    '/etc/release'
  end

  def release_file_format
    %r[^(?:\s)*(?:Oracle )?Solaris (\d+)]
  end

  def supported_releases
    %w[10 11]
  end

  def arch
    retval = super
    (retval == 'i86pc') ? 'i386' : retval
  end

end
