shared_examples 'provider/provisioner/pe_bootstrap/latest' do |provider, options|
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
    environment.skeleton('pe_latest_acceptance')
    options[:boxes].each do |box|
      name = File.basename(box).split('-').first
      assert_execute('vagrant', 'box', 'add', name, box)
    end
  end

  after(:each) do
    # Ensure any VMs that survived tests are cleaned up.
    execute('vagrant', 'destroy', '--force')
  end

  context 'when installing PE .latest' do
    it 'provisions masters with pe_bootstrap and agents with pe_agent' do
      status('Test: pe_bootstrap master install')
      assert_execute('vagrant', 'up', "--provider=#{provider}", 'pe-latest-master')

      status('Test: pe_bootstrap master running after install')
      result = execute('vagrant', 'ssh',
        'pe-latest-master',
        '-c', 'sudo /opt/puppetlabs/bin/puppet status --terminus=rest')
      expect(result).to exit_with(0)
      expect(result.stdout).to match('"is_alive": true')

      status('Test: pe_agent install')
      result = assert_execute('vagrant', 'up', "--provider=#{provider}", 'pe-latest-agent')

      status('Test: pe_agent signed cert during install')
      result = execute('vagrant', 'ssh',
        'pe-latest-master',
        '-c', 'sudo /opt/puppetlabs/bin/puppet cert list pe-latest-agent.pe-bootstrap.vlan')
      expect(result).to exit_with(0)

      status('Test: pe_agent cert purged when vm destroyed')
      result = assert_execute('vagrant', 'destroy', '-f', 'pe-latest-agent')
      result = execute('vagrant', 'ssh',
        'pe-latest-master',
        '-c', 'sudo /opt/puppetlabs/bin/puppet cert list pe-latest-agent.pe-bootstrap.vlan')
      expect(result.stderr).to match(/Could not find a certificate/)
    end
  end
end
