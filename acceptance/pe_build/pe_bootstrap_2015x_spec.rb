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

  # TODO: Refactor into a shared example so tha this testcase can be run on
  # multiple versions.
  context 'when installing PE 2015.2.x' do
    it 'provisions masters with pe_bootstrap and agents with pe_agent' do
      status('Test: pe_bootstrap master install')
      assert_execute('vagrant', 'up', "--provider=#{provider}", 'pe-20152-master')

      status('Test: pe_bootstrap master running after install')
      result = execute('vagrant', 'ssh',
        'pe-20152-master',
        '-c', 'sudo /opt/puppetlabs/bin/puppet status --terminus=rest')
      expect(result).to exit_with(0)
      expect(result.stdout).to match('"is_alive": true')

      status('Test: pe_agent install')
      result = assert_execute('vagrant', 'up', "--provider=#{provider}", 'pe-20152-agent')

      status('Test: pe_agent signed cert during install')
      result = execute('vagrant', 'ssh',
        'pe-20152-master',
        '-c', 'sudo /opt/puppetlabs/bin/puppet cert list pe-20152-agent.pe-bootstrap.vlan')
      expect(result).to exit_with(0)
    end
  end

  context 'when installing PE 2015.latest' do
    it 'provisions masters with pe_bootstrap and agents with pe_agent' do
      status('Test: pe_bootstrap master install')
      assert_execute('vagrant', 'up', "--provider=#{provider}", 'pe-2015latest-master')

      status('Test: pe_bootstrap master running after install')
      result = execute('vagrant', 'ssh',
        'pe-2015latest-master',
        '-c', 'sudo /opt/puppetlabs/bin/puppet status --terminus=rest')
      expect(result).to exit_with(0)
      expect(result.stdout).to match('"is_alive": true')

      status('Test: pe_agent install')
      result = assert_execute('vagrant', 'up', "--provider=#{provider}", 'pe-2015latest-agent')

      status('Test: pe_agent signed cert during install')
      result = execute('vagrant', 'ssh',
        'pe-2015latest-master',
        '-c', 'sudo /opt/puppetlabs/bin/puppet cert list pe-2015latest-agent.pe-bootstrap.vlan')
      expect(result).to exit_with(0)
    end
  end

end
