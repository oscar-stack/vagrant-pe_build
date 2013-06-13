require 'vagrant'

module PEBuild
class Command
class List < Vagrant.plugin(2, :command)
  def execute
    #raise NotImplementedError
    if File.directory? PEBuild.archive_directory
      @env.ui.info "PE versions available (at #{PEBuild.archive_directory})"
      @env.ui.info "---"

      pathglob = File.join(PEBuild.archive_directory, '*')

      Dir.glob(pathglob).sort.each do |entry|
        @env.ui.info "  - #{File.basename(entry)}"
      end
    else
      @env.ui.warn "No PE versions available at #{PEBuild.archive_directory}"
    end
  end
end
end
end
