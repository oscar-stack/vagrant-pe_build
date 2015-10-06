require 'spec_helper'

require 'pe_build/provisioner/pe_agent'

describe PEBuild::Provisioner::PEAgent do
  include_context 'vagrant-unit'

  subject { described_class.new(machine, config) }

  let(:test_env) do
    env = isolated_environment
    env.vagrantfile("")

    env
  end

  let(:env)          { test_env.create_vagrant_env }
  let(:machine)      { env.machine(env.machine_names[0], :dummy) }
  let(:config)       { PEBuild::Config::PEAgent.new }
  # Mock the communicator to prevent SSH commands from being executed.
  let(:communicator) { double('communicator') }
  # Mock the guest operating system.
  let(:guest)        { double('guest') }
  # Mock Vagrant IO.
  let(:ui)           { double('ui') }

  before(:each) do
    allow(machine).to receive(:communicate).and_return(communicator)
    allow(machine).to receive(:guest).and_return(guest)
    allow(machine).to receive(:ui).and_return(ui)

    config.finalize!
    # Skip provision-time inspection of machines.
    allow(subject).to receive(:provision_init!)
  end

  after(:each) { test_env.close }

  context 'when an agent is installed' do
    before(:each) do
      allow(subject).to receive(:agent_version).and_return('1.0.0')
    end

    it 'logs a message and returns early' do
      expect(ui).to receive(:info).with(/Puppet agent .* is already installed/)
      expect(subject).to_not receive(:provision_posix_agent)

      subject.provision
    end
  end

  context 'when an agent is not installed' do
    before(:each) do
      allow(subject).to receive(:agent_version).and_return(nil)
    end

    it 'invokes the agent provisioner' do
      expect(subject).to receive(:provision_posix_agent)

      subject.provision
    end
  end

end
