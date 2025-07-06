# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ruff/version'

Gem::Specification.new do |spec|
  spec.name          = 'ruff'
  spec.version       = Ruff::VERSION
  spec.authors       = ['Nymphium']
  spec.email         = ['s1311350@gmail.com']

  spec.summary       = 'ONE-SHOT Algebraic Effects for Ruby!'
  spec.description   = 'ONE-SHOT Algebraic Effects for Ruby!'
  spec.homepage      = 'https://github.com/Nymphium/ruff'
  spec.license       = 'MIT'

  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.7.0' # Assuming Ruby 2.7 or higher

  spec.metadata = {
    'documentation_uri' => 'https://nymphium.github.io/ruff',
    'rubygems_mfa_required' => 'true'
  }

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'redcarpet'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'rubocop-rake'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'ruby-lsp'
  spec.add_development_dependency 'yard'
end
