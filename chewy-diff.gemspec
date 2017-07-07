# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chewy/diff/version'

Gem::Specification.new do |spec|
  spec.name          = "chewy-diff"
  spec.version       = Chewy::Diff::VERSION
  spec.authors       = ["Jônatas Davi Paganini"]
  spec.email         = ["jonatas.paganini@toptal.com"]

  spec.summary       = %q{Verify difference between different chewy index declaration}
  spec.description   = %
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"
  spec.add_dependency "ffast", "0.0.1"
  spec.add_dependency "parser", "~> 2.4.0.0"
end
