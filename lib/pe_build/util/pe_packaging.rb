module PEBuild
  module Util
    # Utilities related to PE Packages
    #
    # This module provides general-purpose utility functions for working with
    # PE packages.
    #
    # @since 0.13.0
    module PEPackaging

      # Determine package tag from Facts
      #
      # The `platform_tag` is a `os-version-archtecture` value that is used in
      # many PE package filenames and repostiory names.
      #
      # @param facts [Hash] A hash of facts which includes `architecture`
      #   and `os` values.
      #
      # @return [String] A string representing the platform tag.
      def platform_tag(facts)
        case facts['os']['family'].downcase
        when 'redhat'
          # TODO: Fedora might be in here.
          os      = 'el'
          version = facts['os']['release']['major']
          arch    = facts['architecture']
        when 'windows'
          os      = 'windows'
          # Windows packages don't discriminate based on version.
          version = nil
          arch    = (facts['architecture'] == 'x64' ? 'x86_64' : 'i386')
        when 'debian'
          case os = facts['os']['name'].downcase
          when 'debian'
            version = facts['os']['release']['major']
          when 'ubuntu'
            version = facts['os']['release']['full']
          end
          # TODO: Add "unknown debian" error.
          arch = (facts['architecture'] == 'x86_64' ? 'amd64' : 'i386')
        when 'solaris'
          os      = 'solaris'
          version = facts['os']['release']['major']
          arch    = (facts['architecture'].match(/^i\d+/) ? 'i386' : 'sparc')
        when 'suse'
          os      = 'sles'
          version = facts['os']['release']['major']
          arch    = facts['architecture']
        end
        # TODO: Add "unknown os" error.

        [os, version, arch].compact.join('-').downcase
      end
      module_function :platform_tag

    end
  end
end
