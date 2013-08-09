# -*- encoding: utf-8 -*-
require File.expand_path('../lib/hudson-remote-cli/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['GuyCheung']
  gem.email         = ['guy.xtafcusqt@gmail.com']
  gem.description   = %q{Ruby interface to Hudson's remote json API}
  gem.summary       = %q{Ruby interface to Hudson's remote json API}
  gem.homepage      = 'https://github.com/GuyCheung/hudson-remote-cli'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "hudson-remote-cli"
  gem.require_paths = ["lib"]
  gem.version       = Hudson::VERSION
end
