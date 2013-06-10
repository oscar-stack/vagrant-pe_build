require 'pe_build/archive'
require 'vagrant'
require 'fileutils'

module PEBuild
module Action
class Download
  # Downloads a PE build to a temp directory

  def initialize(app, env)
    @app, @env = app, env
    load_variables
  end

  def call(env)
    @env = env
    perform_download
    @app.call(@env)
  end

  private

  # Determine system state and download a PE build accordingly.
  #
  # If we are applying actions within the context of a single box, then we
  # should try to prefer and box level configuration options first. If
  # anything is unset then we should fall back to the global settings.
  #
  # @todo this is the worst damn thing ever. It needs to be purged. These
  #   variables should be _explicitly passed_ and let the caller figure this
  #   out. It's a disgusting amount of data munging that's hardly our
  #   responsibility. Although really, this class should be killed. Killed dead.
  #
  def load_variables
    if @env[:box_name]
      @root     = @env[:vm].pe_build.download_root
      @version  = @env[:vm].pe_build.version
      @filename = @env[:vm].pe_build.filename
    end

    @root     ||= @env[:global_config].pe_build.download_root
    @version  ||= @env[:global_config].pe_build.version
    @filename ||= @env[:global_config].pe_build.filename
  end

  def perform_download
    archive = PEBuild::Archive.new(@filename, @version)
    archive.ui = @env[:ui]
    archive.download(@root)
  end
end
end
end
