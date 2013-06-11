require 'vagrant'

module PEBuild
class Command
class List < Vagrant.plugin(2, :command)
  def execute
    raise NotImplementedError
    if File.directory? PEBuild.archive_directory and (entries = Dir["#{PEBuild.archive_directory}/*"])
      puts entries.join("\n")
    else
      warn "No PE versions downloaded."
    end
  end
end
end
end
