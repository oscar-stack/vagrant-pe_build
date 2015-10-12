shared_examples 'provider/provisioner/pe_bootstrap/2015x' do |provider, options|
  if options[:boxes].empty?
    raise ArgumentError,
      "Box files must be downloaded for provider: #{provider}. Try: rake acceptance:setup"
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
    options[:boxes].each do |box|
      name = File.basename(box).split('-').first
      assert_execute('vagrant', 'box', 'add', name, box)
    end
  end

  after(:each) do
    # Ensure any VMs that survived tests are cleaned up.
    assert_execute('vagrant', 'destroy', '--force', log: false)
  end

  context 'when installing PE 2015.2.x' do
    it 'provisions masters with pe_bootstrap and agents with pe_agent' do
      assert_execute('vagrant', 'up', "--provider=#{provider}", 'pe-20152-master')
      assert_execute('vagrant', 'up', "--provider=#{provider}", 'pe-20152-agent')
    end
  end

  context 'when installing PE 2015.latest' do
    it 'provisions masters with pe_bootstrap and agents with pe_agent' do
      assert_execute('vagrant', 'up', "--provider=#{provider}", 'pe-2015latest-master')
      assert_execute('vagrant', 'up', "--provider=#{provider}", 'pe-2015latest-agent')
    end
  end
end
