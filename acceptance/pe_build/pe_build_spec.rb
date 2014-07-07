shared_examples 'provider/provisioner/pe_build' do |provider, options|
  if !File.file?(options[:box])
    raise ArgumentError,
      "A box file must be downloaded for provider: #{provider}. Try: rake acceptance:setup"
  end

  include_context 'acceptance'

  before(:each) do
    environment.skeleton('pe_build')
    assert_execute('vagrant', 'box', 'add', 'box', options[:box])
  end

  after(:each) do
    # Ensure any VMs that survived tests are cleaned up.
    assert_execute('vagrant', 'destroy', '--force', log: false)
  end

  context 'when download_root is set to a local directory' do
    let(:extra_env) do
      vars = options[:env_vars].dup
      vars['PE_BUILD_DOWNLOAD_ROOT'] = options[:archive_path]

      vars
    end

    it 'provisions with pe_build' do
      assert_execute('vagrant', 'up', "--provider=#{provider}", 'explicit-version')
      assert_execute('vagrant', 'up', "--provider=#{provider}", 'latest-version')
    end
  end

  context 'when download_root is set to a webserver' do
    let(:webserver_port) { 3838 }
    let(:webserver_path) { options[:archive_path] }
    include_context 'webserver'

    let(:extra_env) do
      vars = options[:env_vars].dup
      vars['PE_BUILD_DOWNLOAD_ROOT'] = "http://localhost:#{webserver_port}/"

      vars
    end

    it 'provisions with pe_build' do
      assert_execute('vagrant', 'up', "--provider=#{provider}", 'explicit-version')
      assert_execute('vagrant', 'up', "--provider=#{provider}", 'latest-version')
    end
  end
end
