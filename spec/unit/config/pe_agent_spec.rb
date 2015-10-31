require 'spec_helper'

require 'pe_build/config'

describe PEBuild::Config::PEAgent do
  let(:machine)  { double('machine') }
  let(:env) { double('vagrant environment') }

  before(:each) do
    allow(machine).to receive(:env).and_return(env)
    allow(env).to receive(:machine_names).and_return([:master])
  end

  describe 'autosign' do
    it 'defaults to true if master_vm is set' do
      subject.master_vm = 'master'
      subject.finalize!

      expect(subject.autosign).to eq true
    end

    context 'when master_vm is unset' do
      it 'defaults to false' do
        subject.master_vm = nil
        subject.finalize!

        expect(subject.autosign).to eq false
      end

      it 'fails validation if set to true' do
        subject.master    = 'some-hostname'
        subject.master_vm = nil
        subject.autosign  = true
        subject.finalize!

        errors = subject.validate(machine)

        expect(errors['pe_agent provisioner'].to_s).to match(/Use of the .* setting requires master_vm/)
      end
    end
  end

  describe 'autopurge' do
    it 'defaults to true if master_vm is set' do
      subject.master_vm = 'master'
      subject.finalize!

      expect(subject.autopurge).to eq true
    end

    context 'when master_vm is unset' do
      it 'defaults to false' do
        subject.master_vm = nil
        subject.finalize!

        expect(subject.autopurge).to eq false
      end

      it 'fails validation if set to true' do
        subject.master    = 'some-hostname'
        subject.master_vm = nil
        subject.autopurge = true
        subject.finalize!

        errors = subject.validate(machine)

        expect(errors['pe_agent provisioner'].to_s).to match(/Use of the .* setting requires master_vm/)
      end
    end
  end

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

      # Comparision against an empty array produces a better diff.
      expect(errors['pe_agent provisioner']).to eq []
    end
  end

  describe 'master_vm' do
    it 'must be set to a defined machine' do
      allow(env).to receive(:machine_names).and_return([:master])

      subject.master_vm = 'some_machine'
      subject.finalize!

      errors = subject.validate(machine)

      expect(errors['pe_agent provisioner'].to_s).to match(/The specified master_vm,.*, is not defined/)
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

      expect(errors['pe_agent provisioner']).to eq []
    end

    it 'may be of the form x.y.z[-other-arbitrary-stuff]' do
      subject.version = '2015.2.1-r42-gsomesha'

      subject.finalize!
      errors = subject.validate(machine)

      expect(errors['pe_agent provisioner']).to eq []
    end

    it 'may not be x.y' do
      subject.version = '2015.2'

      subject.finalize!
      errors = subject.validate(machine)

      # Casting the array to a string and using a regex matcher gives a nice
      # diff in the case of failure.
      expect(errors['pe_agent provisioner'].to_s).to match(/The agent version.*is invalid./)
    end

    it "may be greater than or equal to #{PEBuild::Config::PEAgent::MINIMUM_VERSION}" do
      subject.version = PEBuild::Config::PEAgent::MINIMUM_VERSION

      subject.finalize!
      errors = subject.validate(machine)

      expect(errors['pe_agent provisioner']).to eq []
    end

    it "may not be less than #{PEBuild::Config::PEAgent::MINIMUM_VERSION}" do
      subject.version = '3.8.2'

      subject.finalize!
      errors = subject.validate(machine)

      expect(errors['pe_agent provisioner'].to_s).to match(/The agent version.*is too old./)
    end
  end

end
