class PEBuild::Cap::DetectInstaller::Redhat < PEBuild::Cap::DetectInstaller::Base

  def release_file
    '/etc/redhat-release'
  end

  def detect
    supported_releases = %w[5 6]
    regex              = %r[release (\d+)\.\d+]

    release = release_content.match(regex)[1].to_i

    unless supported_releases.include? major_release
      raise "Redhat release #{major_release} not supported"
    end

    installer_name "el-#{major_release}"
  end
end
