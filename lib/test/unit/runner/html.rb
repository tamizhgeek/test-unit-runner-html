# coding: utf-8
require 'test/unit'
require File.expand_path(File.dirname(__FILE__) + '/html-version.rb')


module Test
  module Unit
    AutoRunner.register_runner(:html) do |auto_runner|
      require  'test/unit/ui/html/html_runner.rb'
#      require  File.expand_path(File.dirname(__FILE__) + '/../ui/html/html_runner.rb')
      Test::Unit::UI::Html::HtmlTestRunner
    end
  end
end

# Copyright (c) 2013 Azhagu Selvan SP <tamizhgeek@gmail.com> ( LGPL V3.0)
