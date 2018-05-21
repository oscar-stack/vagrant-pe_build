shared_examples 'provider/provisioner/pe_bootstrap/latest' do |provider, options|
  if options[:boxes].empty?
    raise ArgumentError,
      "Box files must be downloaded for provider: #{provider}. Try: rake acceptance:setup"
  end

  include_context 'acceptance'

  let(:webserver_port) { 3838 }
  let(:webserver_path) { options[:archive_path] }
  let(:extra_env) do
    vars = options[:env_vars].dup
    vars['PE_BUILD_DOWNLOAD_ROOT'] = "http://localhost:#{webserver_port}"

    vars
  end

  include_context 'webserver'

  before(:each) do
    environment.skeleton('pe_build')
    options[:boxes].each do |box|
      name = File.basename(box).split('-').first
      assert_execute('vagrant', 'box', 'add', name, box)
    end
  end

  after(:each) do
    # Ensure any VMs that survived tests are cleaned up.
    execute('vagrant', 'destroy', '--force')
  end

  context 'when installing LATEST from a build server' do
    it 'provisions with pe_build' do
      assert_execute('vagrant', 'up', "--provider=#{provider}", 'pe-latest')
    end
  end
end
