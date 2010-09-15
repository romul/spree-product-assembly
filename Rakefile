# encoding: utf-8
require 'rubygems'
begin
  require 'jeweler'
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
  exit 1
end
#gem 'rdoc', '= 2.2'
require 'rdoc'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/packagetask'
require 'rake/gempackagetask'

Jeweler::Tasks.new do |s|
  s.name = "spree_product_assembly"
  s.summary = "Adds oportunity to make bundle of products to your Spree store."
  s.description = s.summary
  s.email = "roman@railsdog.com"
  s.homepage = "http://github.com/spree/spree-product-assembly"
  s.authors = ["Roman Smirnov"]
  s.add_dependency 'spree_core', ['>= 0.30.0.beta1']
  #s.has_rdoc = false
  #s.extra_rdoc_files = [ "README.rdoc"]
  #s.rdoc_options = ["--main", "README.rdoc", "--inline-source", "--line-numbers"]
  #s.test_files = Dir['test/**/*.{yml,rb}']
end
Jeweler::GemcutterTasks.new

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the product_assembly extension.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

namespace :test do
  desc 'Functional test the product_assembly extension.'
  Rake::TestTask.new(:functionals) do |t|
    t.libs << 'lib'
    t.pattern = 'test/functional/*_test.rb'
    t.verbose = true
  end

  desc 'Unit test the product_assembly extension.'
  Rake::TestTask.new(:units) do |t|
    t.libs << 'lib'
    t.pattern = 'test/unit/*_test.rb'
    t.verbose = true
  end
end

desc 'Generate documentation for the product_assembly extension.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'ProductAssemblyExtension'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.markdown')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

# Load any custom rakefiles for extension
# Dir[File.dirname(__FILE__) + '/lib/tasks/*.rake'].sort.each { |f| require f }
