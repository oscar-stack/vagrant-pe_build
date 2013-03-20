require 'vagrant'
require 'vagrant/action/builder'

require 'pe_build/action/download'
require 'pe_build/action/unpackage'


module PEBuild
module Action

  def self.stage_pe_action
    Vagrant::Action::Builder.new.tap do |b|
      b.use PEBuild::Action::Download
      b.use PEBuild::Action::Unpackage
    end
  end

end
end
