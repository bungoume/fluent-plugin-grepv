# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "fluent-plugin-grepv"
  s.version     = "0.0.1"
  s.authors     = ["Yuri Umezaki"]
  s.email       = ["bungoume@gmail.com"]
  s.homepage    = "https://github.com/bungoume/fluent-plugin-grepv"
  s.summary     = "Fluentd filter plugin to exclude messages"
  s.description = s.summary
  s.licenses    = ["MIT"]

  s.rubyforge_project = "fluent-plugin-grepv"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "fluentd"
  s.add_runtime_dependency "string-scrub" if RUBY_VERSION.to_f < 2.1
  s.add_development_dependency "rake"
  s.add_development_dependency "test-unit"
  s.add_development_dependency "pry"
  s.add_development_dependency "pry-nav"
end
