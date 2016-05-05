# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'boolean-search/version'

Gem::Specification.new do |spec|
  spec.name          = "boolean-search"
  spec.version       = Boolean::Search::VERSION
  spec.authors       = ["Chakrit Wichian"]
  spec.email         = ["service@chakrit.net"]

  spec.summary       = "Provides a parser for standard boolean search sytax."
  spec.homepage      = "https://github.com/chakrit/boolean-search"
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-minitest"
end
