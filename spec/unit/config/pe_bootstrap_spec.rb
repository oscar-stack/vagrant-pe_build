require 'spec_helper'

require 'pe_build/config'

describe PEBuild::Config::PEBootstrap do
  let(:machine)  { double('machine') }

  context 'when finalized with default values' do
    before(:each) { subject.finalize! }

    it 'passes validation' do
      errors = subject.validate(machine)

      expect(errors).to include('PE Bootstrap' => [])
    end
  end

  # TODO: Spec test the validation functions. Not critical right now since it
  # is pretty much testing tests. But, having specs is a good way for people to
  # see precisely _what_ is allowed.

end
