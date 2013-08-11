module PEBuild
  module Cap
    module DetectInstaller
      require 'pe_build/cap/detect_installer/base'

      require 'pe_build/cap/detect_installer/redhat'
      require 'pe_build/cap/detect_installer/debian'
      require 'pe_build/cap/detect_installer/ubuntu'
      #require 'pe_build/cap/detect_installer/suse'
    end

    module RunInstall
      require 'pe_build/cap/run_install/posix'
    end
  end
end
