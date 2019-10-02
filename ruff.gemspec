
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ruff/version"

Gem::Specification.new{|spec|
  spec.name          = "ruff"
  spec.version       = Ruff::VERSION
  spec.authors       = ["nymphium"]
  spec.email         = ["s1311350@gmail.com"]

  spec.summary       = %q{ONE-SHOT Algebraic Effects for Ruby!}
  spec.description   = %q{ONE-SHOT Algebraic Effects for Ruby!}
  spec.homepage      = "https://github.com/nymphium/ruff"
  spec.license       = "MIT"
  

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.metadata = {
    "documentation_uri" => "https://nymphium.github.io/ruff",
    "bug_tracker_uri" => "https://github/nymphium/ruff/issues"
  }
}
