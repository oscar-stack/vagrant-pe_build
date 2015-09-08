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

  describe 'answer_extras' do
    it 'defaults to an empty Array' do
      subject.finalize!

      expect(subject.answer_extras).to be_a(Array)
    end

    context 'when validated with a non-array value' do
      it 'records an error' do
        subject.answer_extras = {'' => ''}

        subject.finalize!
        errors = subject.validate(machine)

        expect(errors['PE Bootstrap'].to_s).to match(/Answer_extras.*got a Hash/)
      end
    end
  end

  # TODO: Spec test the validation functions. Not critical right now since it
  # is pretty much testing tests. But, having specs is a good way for people to
  # see precisely _what_ is allowed.

end
