require 'vagrant'

module PEBuild
class Command
class Download < Vagrant.plugin(2, :command)
  def execute
    raise NotImplementedError
    #@env.action_runner.run(:download_pe_build)
  end
end
end
end
