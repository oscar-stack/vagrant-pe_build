require 'config_builder'

module PEBuild
  module ConfigBuilder
    class PEBootstrap < ::ConfigBuilder::Model

      attr_accessor :role
      attr_accessor :relocate_manifests

      def to_proc
        Proc.new do |vm_config|
          vm_config.provision :pe_bootstrap do |pe|
            pe.role = @role if defined? @role
            pe.relocate_manifests = @relocate_manifests if defined? @relocate_manifests
          end
        end
      end

      ::ConfigBuilder::ModelCollection.provisioner.register('pe_bootstrap', self)
    end
  end
end
