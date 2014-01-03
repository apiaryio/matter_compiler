# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'matter_compiler/version'

Gem::Specification.new do |spec|
  spec.name          = "matter_compiler"
  spec.version       = MatterCompiler::VERSION
  spec.authors       = ["Zdenek Nemec"]
  spec.email         = ["z@apiary.io"]
  spec.summary       = %q{API Blueprint AST to API Blueprint convertor}
  spec.description   = nil
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "cucumber"
  spec.add_development_dependency "minitest"
  
  # Use latest aruba for STDIN capabilities, see the Gemfile
  # spec.add_development_dependency "aruba"
end
