lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'mongoid/searchable/version'

Gem::Specification.new do |s|

  s.name = 'mongoid-searchable'
  s.version = Mongoid::Searchable::VERSION
  s.authors = ['Jason Coene']
  s.email = ['jcoene@gmail.com']
  s.homepage = 'http://github.com/jcoene/mongoid-searchable'
  s.summary = 'Simple keyword search for your Mongoid models.'
  s.description = 'Mongoid Searchable allows you to easily perform full-text search your Mongoid models.'

  s.add_dependency 'mongoid', '~> 2.4'
  s.add_dependency 'bson_ext', '~> 1.6'
  s.add_development_dependency 'growl'
  s.add_development_dependency 'rake', '~> 0.9.2'
  s.add_development_dependency 'rspec', '~> 2.9'
  s.add_development_dependency 'guard-rspec', '~> 0.7'

  s.files = Dir["lib/**/*"] + ["MIT-LICENSE", "Rakefile", "Gemfile", "README.md"]
  s.require_paths = ['lib']

end
