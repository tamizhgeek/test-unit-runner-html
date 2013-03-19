#!/usr/bin/env ruby
require 'rubygems'
$VERBOSE = true

$KCODE = "utf8" unless "".respond_to?(:encoding)

base_dir = File.expand_path(File.join(File.dirname(__FILE__), ".."))
lib_dir = File.join(base_dir, "lib")
test_dir = File.join(base_dir, "test")

$LOAD_PATH.unshift(lib_dir)

gem 'test-unit'  # until require 'test-unit'

require 'test/unit'


files = Dir[File.join(test_dir, 'test_html.rb')]

exit Test::Unit::AutoRunner.run(true, test_dir, files)

