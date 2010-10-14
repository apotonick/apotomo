require "rubygems"
require "bundler"

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

$:.unshift File.dirname(__FILE__)+"/lib" # add current dir to LOAD_PATHS

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the Apotomo plugin.'
  Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.test_files = FileList['test/unit/*_test.rb', 'test/rails/*_test.rb']# - ['test/rails/capture_test.rb']
  t.verbose = true
end


require 'jeweler'
require 'apotomo/version'

Jeweler::Tasks.new do |spec|
  spec.name         = "apotomo"
  spec.version      = ::Apotomo::VERSION
  spec.summary      = %{Web components for Rails.}
  spec.description  = "Web components for Rails. Event-driven. Clean. Fast. Free optional statefulness included."
  spec.homepage     = "http://apotomo.de"
  spec.authors      = ["Nick Sutterer"]
  spec.email        = "apotonick@gmail.com"

  spec.files = FileList["[A-Z]*", File.join(*%w[{generators,lib,rails,app,config} ** *]).to_s]
  spec.test_files   = FileList["test/**/*"] - FileList["test/dummy/tmp/**/*", "test/dummy/log/*"]
  
  spec.add_dependency 'cells', '~> 3.4.2'
  spec.add_dependency 'rails', '>= 3.0.0'
  spec.add_dependency 'onfire', '>= 0.1.0'
  spec.add_dependency 'hooks', '~> 0.1.2'
end

Jeweler::GemcutterTasks.new
