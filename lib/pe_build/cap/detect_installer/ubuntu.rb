class PEBuild::Cap::DetectInstaller::Debian < PEBuild::Cap::DetectInstaller::Base

  def release_file
    '/etc/issue'
  end

  def detect
    supported_releases = %w[10.04 12.04]
    regex              = %r[Ubuntu (\d{2}\.\d{2})]

    release = release_content.match(regex)[1]

    unless supported_releases.include? major_release
      raise "Debian release #{major_release} not supported"
    end

    installer_name "ubuntu-#{major_release}"
  end
end
