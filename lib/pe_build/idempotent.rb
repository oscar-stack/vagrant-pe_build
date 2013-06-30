module PEBuild
module Idempotent

  # @param fpath [String]
  # @param desc [String, nil]
  def idempotent(fpath, desc = nil, &block)
    desc ||= fpath

    if File.exist? fpath
      @env.ui.warn "#{desc} is already present.", :prefix => true
    else
      yield
    end
  end
end
end
