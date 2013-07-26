require 'config_builder/model'

module PEBuild
  module ConfigBuilder
    class Global < ::ConfigBuilder::Model::Base

      # @!attribute [rw] download_root
      attr_accessor :download_root

      # @!attribute [rw] version
      attr_accessor :version

      # @!attribute [rw] suffix
      attr_accessor :suffix

      # @!attribute [rw] filename
      attr_accessor :filename

      def to_proc
        Proc.new do |global_config|
          global_config.pe_build.download_root = @download_root if defined? @download_root
          global_config.pe_build.version       = @version       if defined? @version
          global_config.pe_build.suffix        = @suffix        if defined? @suffix
          global_config.pe_build.filename      = @filename      if defined? @filename
        end
      end
    end
  end
end
