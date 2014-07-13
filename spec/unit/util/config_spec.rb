require 'spec_helper'

require 'pe_build/config'
require 'pe_build/util/config'


describe PEBuild::Util::Config do
  let(:global) { PEBuild::Config::Global.new }
  let(:local)  { PEBuild::Config::PEBootstrap.new }

  before(:each) do
    global.finalize!
    local.finalize!
  end

  describe 'when merging global and local configs' do

    describe 'merged version' do
      it 'is inherited from global if local is unset' do
        global.version = '3.0.0'

        result = subject.local_merge(local, global)

        expect(result.version).to eq('3.0.0')
      end

      it 'is equal to local if set' do
        global.version = '3.0.0'
        local.version = '2.7.0'

        result = subject.local_merge(local, global)

        expect(result.version).to eq('2.7.0')
      end

      it 'is nil if neither global nor local is set' do
        result = subject.local_merge(local, global)

        expect(result.version).to be_nil
      end
    end

  end
end
