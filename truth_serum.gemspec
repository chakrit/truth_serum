# vim: filetype=ruby
# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'truth_serum/version'

Gem::Specification.new do |spec|
  spec.name          = "truth_serum"
  spec.version       = TruthSerum::VERSION
  spec.authors       = ["Chakrit Wichian"]
  spec.email         = ["chakrit@omise.co"]

  spec.summary       = "Parser for github-style search."
  spec.homepage      = "https://github.com/chakrit/truth_serum"
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.licenses      = ["MIT"]
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler",        '~> 1.12'
  spec.add_development_dependency "rake",           '~> 11.2'
  spec.add_development_dependency "minitest",       '~> 5.9'
  spec.add_development_dependency "guard",          '~> 2.14'
  spec.add_development_dependency "guard-minitest", '~> 2.4'
  spec.add_development_dependency "pry",            '~> 0.10'
end
