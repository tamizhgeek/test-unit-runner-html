require File.expand_path("../lib/test/unit/runner/html-version", __FILE__)

root = File.expand_path(File.dirname(__FILE__))
Gem::Specification.new do |s|
  s.name        = "test-unit-runner-html"
  s.version     = Test::Unit::Runner::Html::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Azhagu Selvan SP']
  s.email       = ['tamizhgeek@gmail.com']
  s.homepage    = "http://github.com/tamizhgeek/test-unit-runner-html"
  s.summary     = "Test::Unit runner which can emit customizable html reports"
  s.description = "Test::Unit runner which can emit customizable html reports"

  s.required_rubygems_version = ">= 1.3.6"
#  s.rubyforge_project         = "foodie"
  s.add_dependency "test-unit"
  s.add_dependency "mustache", ">= 1.0.5"
  s.add_development_dependency "bundler", ">= 1.0.0"

  s.files = Dir[root + '/**/*'].reject { |e| e =~ /ruby\.iml|build\.desc/ }.map { |e| e.sub(root + '/', '') }
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_paths = ['lib']
end
