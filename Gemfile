source 'https://rubygems.org'
ruby '2.0.0' # Required by Vagrant 1.4 and newer.

ENV['TEST_VAGRANT_VERSION'] ||= 'v1.6.3'

# Wrapping gemspec in the :plugins group causes Vagrant 1.5 and newer to
# automagically load this plugin during acceptance tests.
group :plugins do
  gemspec
end

group :doc do
  gem 'yard', '~> 0.8.7'
  gem 'redcarpet'
end

group :test do
  if ENV['TEST_VAGRANT_VERSION'] == 'HEAD'
    gem 'vagrant', :github => 'mitchellh/vagrant', :branch => 'master'
  else
    gem 'vagrant', :github => 'mitchellh/vagrant', :tag => ENV['TEST_VAGRANT_VERSION']
  end

  # Pinned on 05/05/2014. Compatible with Vagrant 1.5.x and 1.6.x.
  gem 'vagrant-spec', :github => 'mitchellh/vagrant-spec', :ref => 'aae28ee'
end

eval_gemfile "#{__FILE__}.local" if File.exists? "#{__FILE__}.local"
