require 'spec_helper'

require 'pe_build/config'

describe PEBuild::Config::PEAgent do
  let(:machine)  { double('machine') }

  describe 'master' do
    it 'must be set if master_vm is nil' do
      subject.master_vm = nil
      subject.finalize!

      errors = subject.validate(machine)

      expect(errors['pe_agent provisioner'].to_s).to match(/No master or master_vm setting has been configured/)
    end

    it 'may be unset if master_vm is not nil' do
      subject.master_vm = 'master'
      subject.finalize!

      errors = subject.validate(machine)

      expect(errors['pe_agent provisioner']).to be_empty
    end
  end

  describe 'version' do
    before(:each) { subject.master = 'master.company.com' }

    it 'defaults to "current"' do
      subject.finalize!

      expect(subject.version).to eq 'current'
    end

    it 'may be of the form x.y.z' do
      subject.version = '2015.2.1'

      subject.finalize!
      errors = subject.validate(machine)

      expect(errors['pe_agent provisioner']).to be_empty
    end

    it 'may be of the form x.y.z[-other-arbitrary-stuff]' do
      subject.version = '2015.2.1-r42-gsomesha'

      subject.finalize!
      errors = subject.validate(machine)

      expect(errors['pe_agent provisioner']).to be_empty
    end

    it 'may not be x.y' do
      subject.version = '2015.2'

      subject.finalize!
      errors = subject.validate(machine)

      # Casting the array to a string and using a regex matcher gives a nice
      # diff in the case of failure.
      expect(errors['pe_agent provisioner'].to_s).to match(/The agent version.*is invalid./)
    end

    it "must be greater than #{PEBuild::Config::PEAgent::MINIMUM_VERSION}" do
      subject.version = '3.8.2'

      subject.finalize!
      errors = subject.validate(machine)

      expect(errors['pe_agent provisioner'].to_s).to match(/The agent version.*is too old./)
    end
  end

end
