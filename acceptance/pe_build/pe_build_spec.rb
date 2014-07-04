shared_examples 'provider/provisioner/pe_build' do |provider, options|
  if !File.file?(options[:box])
    raise ArgumentError,
      "A box file must be downloaded for provider: #{provider}. Try: rake acceptance:setup"
  end

  include_context 'acceptance'
  let(:extra_env) { options[:env_vars] }

  before(:each) do
    environment.skeleton('pe_build')
    assert_execute('vagrant', 'box', 'add', 'box', options[:box])
  end

  after(:each) do
    # Ensure any VMs that survived tests are cleaned up.
    assert_execute('vagrant', 'destroy', '--force', log: false)
  end

  it 'provisions with pe_build' do
    result = assert_execute('vagrant', 'up', "--provider=#{provider}")
  end
end
