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

  gem.add_dependency 'vagrant', '>= 1.1.0'
  gem.add_dependency 'progressbar'

  gem.files        = %x{git ls-files -z}.split("\0")
  gem.require_path = 'lib'
end
