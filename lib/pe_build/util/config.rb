module PEBuild
  module Util
    module Config

      # Merge configuration classes together with the "local" object overwriting any
      # values set in the "other" object. This uses the default merging in the Vagrant
      # plugin config class. The builtin merge function is not straight forward however.
      # It needs to be called on the object being overwritten. When using a subclass of
      # a global config for a provisioner config, the builtin merge method cannot actually
      # merge them in the direction that would be needed.
      #
      # This function assumes that the "local" object is of the same class or at the very
      # least a subclass of "other".
      #
      # @param local [Vagrant::Plugin::V2::Config] Local configuration class to merge
      # @param other [Vagrant::Plugin::V2::Config] Other configuration class to merge
      # @return [Vagrant::Plugin::V2::Config] New object of the same class as Local that represents the merged result
      #
      def self.local_merge(local, other)
        if other.class >= local.class
          result = local.class.new

          result = result.merge(other)
          result = result.merge(local)
        end
      end
    end
  end
end
