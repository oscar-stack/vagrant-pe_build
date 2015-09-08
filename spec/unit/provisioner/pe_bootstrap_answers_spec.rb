require 'spec_helper'

require 'pe_build/provisioner/pe_bootstrap'

describe PEBuild::Provisioner::PEBootstrap::AnswersFile do
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

  # Mock the communicator to prevent SSH commands from being executed.
  let(:communicator)     { double('communicator') }
  # Mock the guest operating system.
  let(:guest)            { double('guest') }

  before (:each) do
    machine.stub(:guest => guest)
    machine.stub(:communicator => communicator)
  end

  after(:each) { test_env.close }

  subject do
    provisioner = described_class.new(machine, bootstrap_config, env.root_path.join(PEBuild::WORK_DIR))
    provisioner.stub(:template_data) { "original template" }

    provisioner
  end


  context 'when answer_extras is not configured' do
    before(:each) do
      bootstrap_config.version = '3.8.2'

      bootstrap_config.finalize!
    end

    it 'does not modify the template' do
      expect(subject.render_answers).to eq("original template")
    end
  end

  context 'when answer_extras is configured' do
    before(:each) do
      bootstrap_config.version = '3.8.2'
      bootstrap_config.answer_extras = ['q_foo=bar', 'q_baz=bim']

      bootstrap_config.finalize!
    end

    it 'appends answers to the template' do
      expect(subject.render_answers.lines.last).to eq("q_baz=bim\n")
    end
  end
end
