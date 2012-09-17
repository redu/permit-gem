# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "permit/version"

Gem::Specification.new do |s|
  s.name        = "permit"
  s.version     = Permit::VERSION
  s.authors     = ["Guilherme Cavalcanti"]
  s.email       = ["guiocavalcanti@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "permit"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
  s.add_development_dependency "webmock"
  s.add_development_dependency "ruby-debug"

  s.add_runtime_dependency "faraday", "~> 0.8.4"
  s.add_runtime_dependency "patron", "~> 0.4.18"
  s.add_runtime_dependency "yajl-ruby"
  s.add_runtime_dependency "amqp", "~> 0.9.1"
end
