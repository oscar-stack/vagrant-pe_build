require 'spec_helper'

require 'pe_build/provisioner/pe_bootstrap'

describe PEBuild::Provisioner::PEBootstrap do
  include_context 'vagrant-unit'

  let(:test_env) do
    test_env = isolated_environment
    test_env.vagrantfile <<-EOF
Vagrant.configure('2') do |config|
  config.vm.define :test
end
EOF

    test_env
  end
  let(:env)              { test_env.create_vagrant_env }
  let(:machine)          { env.machine(:test, :dummy) }
  let(:bootstrap_config) { PEBuild::Config::PEBootstrap.new }

  # Mock the communicator to prevent SSH commands for being executed.
  let(:communicator)     { double('communicator') }
  # Mock the guest operating system.
  let(:guest)            { double('guest') }

  before (:each) do
    machine.stub(:guest => guest)
    machine.stub(:communicator => communicator)
  end

  after(:each) { test_env.close }

  subject(:provisioner) { described_class.new(machine, bootstrap_config) }


  describe 'when configured' do
    context 'and no version is set' do
      it 'raises an error' do
        pending 'This is now done in the `provision` method which is difficult to isolate for a test'
        expect { subject.configure(machine.config) }.to raise_error(
          PEBuild::Provisioner::PEBootstrap::UnsetVersionError,
          /version must be set/ )
      end
    end
  end
end
