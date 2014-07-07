module PEBuild
  module Util
    # @api private
    #
    # @since 0.9.0
    module VersionedPath

      # Substitute release information into a path.
      #
      # @param path [String] A path.
      # @param version [String, nil] A string that will be substituted for any
      #   `:version` token in `path`.
      # @param release [String, nil] A string that will be substituted for any
      #   `:release` token in `path`.
      #
      # @return [String]
      def self.versioned_path(path, version = nil, release = nil)
        result = path.dup
        result.gsub!(/:version/, version) unless version.nil?
        result.gsub!(/:release/, release) unless release.nil?

        result
      end

      # FIXME: This code is basically lifted from:
      #
      #     PEBuild::Archive#versioned_path
      #
      # These two uses need to be cleaned up and consolidated.

    end
  end
end
