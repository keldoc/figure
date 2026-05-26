# frozen_string_literal: true

$:.unshift File.expand_path('lib', __dir__)
require 'figure/version'

Gem::Specification.new do |gem|
  gem.name          = 'figure-keldoc'
  gem.version       = Figure::VERSION
  gem.authors       = ['lacravate']
  gem.email         = ['david.elbaz@af83.com']
  gem.homepage      = 'https://github.com/lacravate/figure'
  gem.summary       = "Figure...'s out configuration from YAML files"
  gem.description   = 'A classic configuration store, that turns out Hash definitions to methods, with a management of environment (and Rails environment)'

  gem.files         = `git ls-files app lib`.split("\n")
  gem.platform      = Gem::Platform::RUBY
  gem.require_paths = ['lib']
  gem.rubyforge_project = '[none]'
  gem.add_development_dependency 'rspec'
end
