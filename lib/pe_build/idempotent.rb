module PEBuild
module Idempotent

  # @param fpath [String]
  # @param desc [String, nil]
  def idempotent(fpath, desc = nil, &block)
    desc ||= fpath

    if File.exist? fpath
      @env.ui.info "#{desc} is already present."
    else
      yield
    end
  end
end
end
