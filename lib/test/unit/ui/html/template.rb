# coding: utf-8
# Copyright (c) 2013 Azhagu Selvan SP <tamizhgeek@gmail.com> (LGPL V3.0)
require 'rubygems'
gem 'mustache'
require 'mustache'

TEMPLATE_PATH = File.expand_path(File.dirname(__FILE__) + '/../../../../../templates')

module Test
  module Unit
    module UI
      module Html
        class BasicTemplate < Mustache
          self.template_path = TEMPLATE_PATH
        end
        class Summary < BasicTemplate
          attr_reader :total, :pass
          self.template_name = 'summary'
          def initialize(total_time, total, pass)
            @total_time = total_time
            @total = total
            @pass = pass
            @fail = total - pass
          end

          def total_time
            @total_time
          end

          def fail
            @fail
          end
        end

        class TestSuiteResult < BasicTemplate
          attr_reader :name, :result, :tests, :fault, :counts_total, :counts_pass, :counts_fail, :counts_error
          self.template_name = "test_suite_result"

          def initialize(testcase, tests, counts)
            @name = testcase.name
            @fault = !testcase.passed?
            @result = testcase.passed? ? "Passed" : "Failed"
            @tests = tests
            @counts_total = counts[:total]
            @counts_pass = counts[:pass]
            @counts_fail = counts[:fail]
            @counts_error = counts[:error]
          end
        end

        class Info < BasicTemplate
          attr_reader :name, :size, :started_at
          self.template_name = 'info'

          def initialize(name, started_at, size)
            @start = started_at
            @name = name
            @size = size
          end

          def started_at
            @start
          end
        end

        class Header < BasicTemplate
          # Dummy class to put html headers
          self.template_name = 'header'
        end

        class Footer < BasicTemplate
          self.template_name = 'footer'
          # Dummy class to put html footers
        end
      end #module Html
    end #module UI
  end #module Unit
end #module Test
