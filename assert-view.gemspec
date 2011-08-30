# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "assert/view/version"

Gem::Specification.new do |s|
  s.name        = "assert-view"
  s.version     = Assert::View::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["TODO: Write your name"]
  s.email       = ["TODO: Write your email address"]
  s.homepage    = "http://github.com/__/assert-views"
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency("bundler")
  s.add_development_dependency("assert")

  # s.add_dependency("gem-name", ["~> 0.0"])
end
