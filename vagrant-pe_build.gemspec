lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'pe_build/version'

Gem::Specification.new do |gem|
  gem.name        = "vagrant-pe_build"
  gem.version     = PEBuild::VERSION

  gem.authors  = 'Adrien Thebo'
  gem.email    = 'adrien@somethingsinistral.net'
  gem.homepage = 'https://github.com/adrienthebo/vagrant-pe_build'

  gem.summary     = "Vagrant provisioner for installing Puppet Enterprise"

  gem.files        = %x{git ls-files -z}.split("\0")
  gem.require_path = 'lib'

  gem.license = 'Apache 2.0'

  gem.add_runtime_dependency 'progressbar'
  gem.add_runtime_dependency 'minitar'

  gem.add_development_dependency 'rake'
  # Pin to 2.14.x for compatibility with vagrant-spec.
  gem.add_development_dependency 'rspec', '~> 2.14.0'
end
