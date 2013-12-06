require 'pe_build/archive'
require 'pe_build/command/copy'

class PEBuild::Command::Download < Vagrant.plugin(2, :command)

  def execute
    @env.ui.warn "vagrant pe-build download is deprecated, use vagrant pe-build copy", :prefix => true
    PEBuild::Command::Copy.new(@argv, @env).execute
  end
end
