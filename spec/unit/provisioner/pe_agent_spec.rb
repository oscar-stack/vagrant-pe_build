require 'spec_helper'

require 'pe_build/provisioner/pe_agent'

describe PEBuild::Provisioner::PEAgent do
  include_context 'vagrant-unit'

  subject { described_class.new(agent_vm, config) }

  let(:test_env) do
    env = isolated_environment
    env.vagrantfile <<-EOF
Vagrant.configure('2') do |config|
  config.vm.define :agent_vm
  config.vm.define :master_vm
end
EOF

    env
  end

  let(:env)          { test_env.create_vagrant_env }
  let(:agent_vm)     { env.machine(:agent_vm, :dummy) }
  let(:master_vm)    { env.machine(:master_vm, :dummy) }
  let(:config)       { PEBuild::Config::PEAgent.new }
  # Mock the communicator to prevent SSH commands from being executed.
  let(:agent_comm)   { double('agent_comm') }
  let(:master_comm)  { double('master_comm') }
  # Mock Vagrant IO.
  let(:agent_ui)           { double('agent_ui') }
  let(:master_ui)          { double('master_ui') }

  before(:each) do
    allow(agent_vm).to receive(:communicate).and_return(agent_comm)
    allow(agent_vm).to receive(:ui).and_return(agent_ui)
    allow(master_vm).to receive(:communicate).and_return(master_comm)
    allow(master_vm).to receive(:ui).and_return(master_ui)

    config.finalize!
    # Skip provision-time inspection of machines.
    agent_vm.stub_chain(:guest, :capability)
    allow(subject).to receive(:provision_init!)
  end

  after(:each) { test_env.close }

  context 'when an agent is installed' do
    before(:each) do
      allow(subject).to receive(:agent_version).and_return('1.0.0')
    end

    it 'logs a message and returns early' do
      expect(agent_ui).to receive(:info).with(/Puppet agent .* is already installed/)
      expect(subject).to_not receive(:provision_posix_agent)

      subject.provision
    end
  end

  context 'when an agent is not installed' do
    before(:each) do
      allow(subject).to receive(:agent_version).and_return(nil)
      allow(subject).to receive(:provision_windows?).and_return(false)
    end

    context 'when master_vm is set' do
      before(:each) do
        allow(subject).to receive(:master_vm).and_return(master_vm)
      end

      it 'raises an error if the master_vm is unreachable' do
        allow(master_comm).to receive(:ready?).and_return(false)

        expect { subject.provision }.to raise_error(::PEBuild::Util::MachineComms::MachineNotReachable)
      end
    end

    context 'when osfamily is windows' do
      before(:each) do
        allow(subject).to receive(:provision_windows?).and_return(true)
        allow(subject).to receive(:master_vm).and_return(master_vm)
      end

      it 'invokes the windows provisioner and skips pe_repo' do
        expect(subject).to receive(:provision_windows_agent)
        expect(subject).to receive(:provision_pe_repo).never

        subject.provision
      end
    end

    context 'when osfamily is not windows' do
      it 'invokes the posix agent provisioner' do
        expect(subject).to receive(:provision_posix_agent)

        subject.provision
      end
    end

  end
end
