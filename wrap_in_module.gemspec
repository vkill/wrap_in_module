# -*- encoding: utf-8 -*-
require File.expand_path('../lib/wrap_in_module/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Andrew De Ponte"]
  gem.email         = ["cyphactor@gmail.com"]
  gem.description   = %q{Ruby gem that allows you to load a ruby file into a module. Think scoping bunch of code inside a module.}
  gem.summary       = %q{Ruby gem that allows you to load a ruby file into a module. Think scoping bunch of code inside a module.}
  gem.homepage      = "http://github.com/realpractice/wrap_in_module"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "wrap_in_module"
  gem.require_paths = ["lib"]
  gem.version       = WrapInModule::VERSION
end
