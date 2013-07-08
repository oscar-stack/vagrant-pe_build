require 'vagrant'
require 'pe_build/archive_collection'

module PEBuild
class Command
class List < Vagrant.plugin(2, :command)
  def execute
    if File.directory? PEBuild.archive_directory
      @env.ui.info "PE versions available (at #{PEBuild.archive_directory})"
      @env.ui.info "---"

      collection = PEBuild::ArchiveCollection.new(PEBuild.archive_directory, @env)
      collection.display
    else
      @env.ui.warn "No PE versions available at #{PEBuild.archive_directory}"
    end
  end
end
end
end
