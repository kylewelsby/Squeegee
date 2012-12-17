# -*- encoding: utf-8 -*-
require File.expand_path('../lib/squeegee/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Kyle Welsby"]
  gem.email         = ["kyle@mekyle.com"]
  gem.description   = %q{A collection of strategies to get bill dates and amounts
  from a growing range of accounts.}
  gem.summary       = %q{Returns bill dates and amounts form utility accounts.}
  gem.homepage      = "http://github.com/kylewelsby/squeegee"

  gem.add_runtime_dependency 'mechanize'
  gem.add_runtime_dependency 'logger'

  gem.add_development_dependency "gem-release"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "simplecov"
  gem.add_development_dependency "webmock"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "squeegee"
  gem.require_paths = ["lib"]
  gem.version       = Squeegee::VERSION
end
