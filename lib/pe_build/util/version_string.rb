require 'rubygems/version'

module PEBuild
  module Util
    # @api private
    #
    # @since 0.10.2
    module VersionString

      # Approximate comparison of two version strings using <=>
      #
      # Uses the Gem::Version class. Any nightly build tags, such as
      # `-rc4-165-g9a98c9f`, will be stripped from the version.
      #
      # @param a [String] The first version string.
      # @param b [String] The second version string.
      #
      # @return [Integer] A -1, 0 or 1.
      def self.compare(a, b)
        Gem::Version.new(a.split('-').first) <=> Gem::Version.new(b.split('-').first)
      end
    end
  end
end
