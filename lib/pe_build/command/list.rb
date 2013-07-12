require 'vagrant'
require 'pe_build/archive_collection'

module PEBuild
class Command
class List < Vagrant.plugin(2, :command)
  def execute
    archive_dir = PEBuild.archive_directory(@env)

    if File.directory? archive_dir
      @env.ui.info "PE versions available (at #{archive_dir})"
      @env.ui.info "---"

      collection = PEBuild::ArchiveCollection.new(archive_dir, @env)
      collection.display
    else
      @env.ui.warn "No PE versions available at #{archive_dir}"
    end
  end
end
end
end
