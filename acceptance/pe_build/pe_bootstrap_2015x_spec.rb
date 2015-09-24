shared_examples 'provider/provisioner/pe_bootstrap/2015x' do |provider, options|
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
    environment.skeleton('2015x_acceptance')
    assert_execute('vagrant', 'box', 'add', 'box', options[:box])
  end

  after(:each) do
    # Ensure any VMs that survived tests are cleaned up.
    assert_execute('vagrant', 'destroy', '--force', log: false)
  end

  context 'when installing PE 2015.2.0' do
    it 'provisions with pe_build' do
      result = assert_execute('vagrant', 'up', "--provider=#{provider}", 'pe-201520-master', 'pe-201520-agent')
    end
  end

  context 'when installing PE 2015.2.1' do
    it 'provisions with pe_build' do
      assert_execute('vagrant', 'up', "--provider=#{provider}", 'pe-201521-master', 'pe-201521-agent')
    end
  end

  context 'when installing PE 2015.latest' do
    it 'provisions with pe_build' do
      assert_execute('vagrant', 'up', "--provider=#{provider}", 'pe-2015latest-master', 'pe-2015latest-agent')
    end
  end
end
