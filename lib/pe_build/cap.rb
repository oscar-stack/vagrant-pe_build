module PEBuild
  module Cap
    module DetectInstaller

      class DetectFailed < Vagrant::Errors::VagrantError
        error_key(:detect_failed, 'pebuild.cap.detect_installer')
      end

      require 'pe_build/cap/detect_installer/base'
      require 'pe_build/cap/detect_installer/posix'
      require 'pe_build/cap/detect_installer/windows'

      require 'pe_build/cap/detect_installer/redhat'
      require 'pe_build/cap/detect_installer/debian'
      require 'pe_build/cap/detect_installer/ubuntu'
      require 'pe_build/cap/detect_installer/sles'
      require 'pe_build/cap/detect_installer/solaris'
    end

    module Facts
      require 'pe_build/cap/facts/redhat'
      require 'pe_build/cap/facts/debian'
      require 'pe_build/cap/facts/ubuntu'
      require 'pe_build/cap/facts/suse'
      require 'pe_build/cap/facts/solaris'
      require 'pe_build/cap/facts/windows'
    end

    module RunInstall
      require 'pe_build/cap/run_install/posix'
      require 'pe_build/cap/run_install/windows'
    end

    module StageInstaller
      require 'pe_build/cap/stage_installer/posix'
      require 'pe_build/cap/stage_installer/windows'
    end
  end
end
