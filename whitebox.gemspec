# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'whitebox/version'

Gem::Specification.new do |spec|
  spec.name          = "whitebox"
  spec.version       = Whitebox::VERSION
  spec.authors       = ["Domas"]
  spec.email         = ["domas.bitvinskas@me.com"]
  spec.description   = %q{Financial analysis toolbox.}
  spec.summary       = %q{Financial analysis toolbox.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "securities"
  spec.add_dependency "indicators"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
end
