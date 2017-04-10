
root = File.expand_path(File.dirname(__FILE__))

Gem::Specification.new do |s|
  s.licenses    = ['MIT']
  s.name        = "test-unit-runner-html"
  s.version     = '0.0.2'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Azhagu Selvan SP']
  s.email       = ['tamizhgeek@gmail.com']
  s.homepage    = "http://github.com/tamizhgeek/test-unit-runner-html"
  s.summary     = "Test::Unit::UI::Html::HtmlTestRunner v 0.0.2".freeze
  s.description = "Test::Unit runner which can emit customizable html reports".freeze

  s.required_rubygems_version = ">= 1.3.6".freeze
  s.require_paths = ['lib']
  s.files = Dir[root + '/**/*'].reject { |e| e =~ /ruby\.iml|build\.desc/ }.map { |e| e.sub(root + '/', '') }
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_dependency(%q<test-unit>.freeze, ['>= 0'])
      s.add_runtime_dependency(%q<mustache>.freeze, ['~> 1.0', '>= 1.0.5'])
    else
      s.add_dependency(%q<test-unit>.freeze, ['~> 0'])
      s.add_dependency(%q<mustache>.freeze, ['~> 1.0', '>= 1.0.5'])
    end
  else
    s.add_dependency(%q<test-unit>.freeze, ['~> 0'])
    s.add_dependency(%q<mustache>.freeze, ['~> 1.0', '>= 1.0.5'])
  end
end
