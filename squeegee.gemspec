# -*- encoding: utf-8 -*-
require File.expand_path('../lib/squeegee/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Kyle Welsby", "Chuck Hardy"]
  gem.email         = ["app@britishruby.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = "http://github.com/britruby/squeegee"

  gem.add_runtime_dependency 'mechanize'

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "guard-rspec"
  gem.add_development_dependency "spinach"
  gem.add_development_dependency "simplecov"
  gem.add_development_dependency "vcr"
  gem.add_development_dependency "webmock"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "squeegee"
  gem.require_paths = ["lib"]
  gem.version       = Squeegee::VERSION
end
