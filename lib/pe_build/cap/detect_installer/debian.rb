class PEBuild::Cap::DetectInstaller::Debian < PEBuild::Cap::DetectInstaller::Base

  def release_file
    '/etc/debian_issue'
  end

  def detect
    supported_releases = %w[6 7]
    regex              = %r[^(\d+)\.]

    release = release_content.match(regex)[1]

    unless supported_releases.include? major_release
      raise "Debian release #{major_release} not supported"
    end

    installer_name "debian-#{major_release}"
  end
end
