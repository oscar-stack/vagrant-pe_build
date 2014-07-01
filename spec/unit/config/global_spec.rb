require 'spec_helper'

require 'pe_build/config'

describe PEBuild::Config::Global do
  # The `machine` is a required argument to the validation routine, but
  # currently is not used by the Global config validation checks.
  let(:machine) { double('machine') }

  context 'when finalized with default values' do
    before(:each) { subject.finalize! }

    it 'passes validation' do
      errors = subject.validate(machine)

      expect(errors).to include('PE build global config' => [])
    end
  end

  describe 'version' do
    it 'may be of the form x.y.z' do
      subject.version = '3.0.0'

      subject.finalize!
      errors = subject.validate(machine)

      expect(errors).to include('PE build global config' => [])
    end

    it 'may be of the form x.y.z[-other-arbitrary-stuff]' do
      subject.version = '2.8.0-42-gsomesha'

      subject.finalize!
      errors = subject.validate(machine)

      expect(errors).to include('PE build global config' => [])
    end

    it 'may not be x.y' do
      subject.version = '3.1'

      subject.finalize!
      errors = subject.validate(machine)

      # Casting the array to a string and using a regex matcher gives a nice
      # diff in the case of failure.
      expect(errors['PE build global config'].to_s).to match(/String is malformed/)
    end
  end

  describe 'download_root' do
    PEBuild::Transfer::IMPLEMENTATIONS.keys.compact.each do |scheme|
      it "accepts #{scheme}://" do
        subject.download_root = "#{scheme}://foo"

        subject.finalize!
        errors = subject.validate(machine)

        expect(errors).to include('PE build global config' => [])
      end
    end

    it 'accepts a raw path' do
      subject.download_root = 'foo/bar'

      subject.finalize!
      errors = subject.validate(machine)

      expect(errors).to include('PE build global config' => [])
    end

    it 'rejects foo://' do
      subject.download_root = 'foo://bar'

      subject.finalize!
      errors = subject.validate(machine)

      expect(errors['PE build global config'].to_s).to match(/cannot be handled by any file transferrers/)
    end
  end

end
