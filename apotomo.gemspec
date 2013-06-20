# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'apotomo/version'

Gem::Specification.new do |s|
  s.name        = "apotomo"
  s.version     = Apotomo::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Nick Sutterer"]
  s.email       = ["apotonick@gmail.com"]
  s.homepage    = "http://github.com/apotonick/apotomo"
  s.summary     = %q{Web components for Rails.}
  s.description = %q{Web component framework for Rails providing widgets that trigger events and know when and how to update themselves with AJAX.}
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency "cells",   ">= 3.6.7"
  s.add_dependency "onfire",  "~> 0.2.0"
  s.add_dependency "hooks",   "~> 0.3.0"

  s.add_development_dependency "shoulda"
  s.add_development_dependency "rake"
  s.add_development_dependency "slim"
  s.add_development_dependency "haml"
  s.add_development_dependency "tzinfo"
end
