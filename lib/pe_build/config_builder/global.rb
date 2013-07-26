require 'config_builder/model'

module PEBuild
  module ConfigBuilder
    class Global < ::ConfigBuilder::Model::Base

      ::ConfigBuilder::ModelCollection.provisioner.register('global', self)
    end
  end
end
