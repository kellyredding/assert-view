# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "assert/view/version"

Gem::Specification.new do |s|
  s.name        = "assert-view"
  s.version     = Assert::View::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Kelly Redding"]
  s.email       = ["kelly@kellyredding.com"]
  s.homepage    = "http://github.com/teaminsight/assert-view"
  s.summary     = %q{A collection of views for use in the Assert testing framework}
  s.description = %q{A collection of views for use in the Assert testing framework}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency("bundler")
  s.add_development_dependency("assert")

  s.add_dependency("ansi", ["~> 1.3"])
end
