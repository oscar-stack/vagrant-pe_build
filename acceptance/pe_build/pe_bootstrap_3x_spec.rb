shared_examples 'provider/provisioner/pe_bootstrap/3x' do |provider, options|
  if !File.file?(options[:box])
    raise ArgumentError,
      "A box file must be downloaded for provider: #{provider}. Try: rake acceptance:setup"
  end

  include_context 'acceptance'

  let(:extra_env) do
    vars = options[:env_vars].dup
    vars['PE_BUILD_DOWNLOAD_ROOT'] = options[:archive_path]

    vars
  end

  before(:each) do
    # The skelton sets up a Vagrantfile which expects the OS under test to be
    # available as `box`.
    environment.skeleton('pe_build')
    assert_execute('vagrant', 'box', 'add', 'box', options[:box])
  end

  after(:each) do
    # Ensure any VMs that survived tests are cleaned up.
    assert_execute('vagrant', 'destroy', '--force', log: false)
  end

  context 'when installing PE 3.x' do
    it 'provisions with pe_build' do
      assert_execute('vagrant', 'up', "--provider=#{provider}", 'pe-3x')
    end
  end
end
