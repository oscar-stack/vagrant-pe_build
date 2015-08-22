require 'vagrant-spec/acceptance/output'

module Vagrant
  module Spec
    OutputTester[:no_archives] = lambda do |text|
      text =~ /No PE versions available/
    end

    OutputTester[:pe_available] = lambda do |text|
      text =~ /puppet-enterprise-\d+\.\d\.\d-el-6-x86_64\.tar\.gz/
    end
  end
end


describe 'vagrant CLI: pe-build', component: 'cli/pe-build' do
  include_context 'acceptance'

  let(:options) { config.providers.values.first }

  let(:webserver_port) { 3838 }
  let(:webserver_path) { options[:archive_path] }
  let(:download_url) { "http://localhost:#{webserver_port}" }

  include_context 'webserver'

  before(:each) do
    environment.skeleton('pe_build')
  end

  it 'can download archives from remote servers' do
    result = execute('vagrant', 'pe-build', 'list')
    expect(result).to exit_with(0)
    expect(result.stdout).to match_output(:no_archives)

    result = execute('vagrant', 'pe-build', 'copy',
      "--release=#{options[:pe_latest]}",
      "#{download_url}/puppet-enterprise-:version-el-6-x86_64.tar.gz")
    expect(result).to exit_with(0)

    result = execute('vagrant', 'pe-build', 'list')
    expect(result).to exit_with(0)
    expect(result.stdout).to match_output(:pe_available)
  end

end
