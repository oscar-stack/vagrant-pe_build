require 'config_builder/version'

module PEBuild
  module ConfigBuilder
    require_relative 'config_builder/global'
  end
end

if ConfigBuilder::VERSION > '1.0'
  require_relative 'config_builder/1_x'
else
  require_relative 'config_builder/0_x'
end
