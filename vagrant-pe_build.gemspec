lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'pe_build/version'

Gem::Specification.new do |gem|
  gem.name        = "vagrant-pe_build"
  gem.version     = PEBuild::VERSION

  gem.authors  = ['Adrien Thebo', 'Charlie Sharpsteen']
  gem.email    = ['adrien@somethingsinistral.net', 'source@sharpsteen.net']
  gem.homepage = 'https://github.com/oscar-stack/vagrant-pe_build'

  gem.summary     = "Vagrant provisioners for installing Puppet Enterprise"

  gem.files        = %x{git ls-files -z}.split("\0")
  gem.require_path = 'lib'

  gem.license = 'Apache 2.0'

  gem.add_runtime_dependency 'ruby-progressbar', '~> 1.8.0'
  gem.add_runtime_dependency 'minitar', '~> 0.6.1'

  gem.add_development_dependency 'rake', '~> 10.0'
end
