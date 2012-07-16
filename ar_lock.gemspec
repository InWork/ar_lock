# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ar_lock/version"

Gem::Specification.new do |s|
  s.name        = "ar_lock"
  s.version     = ArLock::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Philip Kurmann"]
  s.email       = ["philip.kurmann@inwork.ch"]
  s.homepage    = ""
  s.summary     = %q{Atomic lock model implemented by Active Record}
  s.description = %q{Atomic lock mode which stores its locks in the database.}

  s.rubyforge_project = "ar_lock"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
