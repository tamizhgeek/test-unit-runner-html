# coding: utf-8
# Copyright (c) 2013 Azhagu Selvan SP <tamizhgeek@gmail.com> (LGPL V3.0)

require 'test/unit/ui/testrunner'
require 'test/unit/ui/testrunnermediator'
require 'stringio'
require 'mustache'
require File.expand_path(File.dirname(__FILE__) + '/template.rb')

module Test
  module Unit
    module UI
      module Html

        # Base class for Html runner.
        #
        class HtmlTestRunner < Test::Unit::UI::TestRunner

          def initialize(suite, options={})
            super

            @output = @options[:output] || STDOUT

            @level = 0

            @_source_cache = {}
            @already_outputted = false
            @top_level = true

            @counts = Hash.new{ |h,k| h[k] = 0 }
            @html_result = ""

          end

          private


          def setup_mediator
            super
          end

          # Attach the listeners to the hooks
          def attach_to_mediator
            @mediator.add_listener(Test::Unit::TestResult::FAULT,                &method(:add_fault)) # Called when a fault in test case occurs
            @mediator.add_listener(Test::Unit::UI::TestRunnerMediator::STARTED,  &method(:before_suite)) # Before running the whole suite
            @mediator.add_listener(Test::Unit::UI::TestRunnerMediator::FINISHED, &method(:after_suite)) # After finishing the whole suite
            @mediator.add_listener(Test::Unit::TestCase::STARTED,         &method(:before_test)) # Before a individual test case
            @mediator.add_listener(Test::Unit::TestCase::FINISHED,        &method(:after_test)) # After a individual test case
#            @mediator.add_listener(Test::Unit::TestSuite::STARTED_OBJECT,        &method(:html_before_case))
 #           @mediator.add_listener(Test::Unit::TestSuite::FINISHED_OBJECT,       &method(:html_after_case))
          end

          #
          # Before everything else.
          #

          def before_suite(result)
            html = Header.render
            @html_result << html
            puts html
            @result = result
            html = Info.new(@suite.to_s, Time.now, @suite.size).render
            @html_result << html
            puts html
          end


          def after_suite(time_taken)
            html = Summary.new(time_taken, @counts[:total], @counts[:pass]).render
            @html_result << html
            puts html
            html = Footer.render
            @html_result << html
            f = File.open("results.html", "w")
            f.write @html_result
          end

          def html_before_case(testcase)
            @level = @level  + 1
          end

          def html_after_case(testcase)
            @level = @level - 1
          end

          def before_test(test)
            # html = TestCaseResult.new(test, @test_start ,{}).render
            # @html_result << html
            # puts html
            capture_output
          end

          def add_fault(fault)
            case fault
            when Test::Unit::Pending
              result = get_error(fault)
            when Test::Unit::Omission
              result = get_error(fault)
            when Test::Unit::Notification
              result = get_note(fault)
            when Test::Unit::Failure
              result = get_fail(fault)
            else
              result = get_error(fault)
            end
            @counts[:total] += 1
            @counts[:fail] += 1
            @already_outputted = true #if fault.critical?
            output = reset_output
            html = TestCaseResult.new(fault.test_name, "Failed", output, result['exception']).render
            @html_result << html
            puts html
          end

          def get_note(note)
            doc = {
              'type' => 'note',
              'text' => note.message
            }
            return doc
          end

          def after_test(test)
            if @already_outputted
              @already_outputted = false
              return nil
            else
              @counts[:total] += 1
              @counts[:pass]  += 1
              output = reset_output
              html = TestCaseResult.new(test, "Passed", output).render
              @html_result << html
              puts html
            end
          end

          def get_error(fault)
            file, line = location(fault.location)
            rel_file   = file.sub(Dir.pwd+'/', '')
            doc = {
              'text' => "error",
              'label' => clean_label(fault.test_name),
              'exception' => {
                'message'   => clean_message(fault.message),
                'class'     => fault.class.name,
                'file'      => rel_file,
                'line'      => line,
                'source'    => source(file)[line-1].strip,
                'snippet'   => code_snippet_string(file, line),
                'backtrace' => filter_backtrace(fault.location)
              }
            }
            return doc
          end


          def get_fail(fault)
            file, line = location(fault.location)
            rel_file   = file.sub(Dir.pwd+'/', '')
            doc = {
              'text' => "todo",
              'label' => clean_label(fault.test_name),
              'expected'    => fault.inspected_expected,
              'returned'    => fault.inspected_actual,
              'exception' => {
                'message'   => clean_message(fault.message),
                'class'     => fault.class.name,
                'file'      => rel_file,
                'line'      => line,
                'source'    => source(file)[line-1].strip,
                'snippet'   => code_snippet_string(file, line),
                'backtrace' => filter_backtrace(fault.location)
              }
            }
            return doc
          end

          # Clean the test case name - remove method brackets
          def clean_label(name)
            name.sub(/\(.+?\)\z/, '').chomp('()')
          end

          # Clean the backtrace of any reference to test framework itself.
          def filter_backtrace(backtrace)
            trace = backtrace

            ## remove backtraces that match any pattern in $RUBY_IGNORE_CALLERS
            #trace = race.reject{|b| $RUBY_IGNORE_CALLERS.any?{|i| i=~b}}

            ## remove `:in ...` portion of backtraces
            trace = trace.map do |bt|
              i = bt.index(':in')
              i ? bt[0...i] :  bt
            end

            ## if the backtrace is empty now then revert to the original
            trace = backtrace if trace.empty?

            ## simplify paths to be relative to current workding diectory
            trace = trace.map{ |bt| bt.sub(Dir.pwd+File::SEPARATOR,'') }

            return trace
          end

          # Return nicely formated String of code lines.
          def code_snippet_string(file, line)
            str = []
            snp = code_snippet_array(file, line)
            max = snp.map{ |n, c| n.to_s.size }.max
            snp.each do |n, c|
              if n == line
                str << "=> %#{max}d %s" % [n, c]
              else
                str << "   %#{max}d %s" % [n, c]
              end
            end
            str.join("\n")
          end

          # Return Array of source code line numbers and text.
          def code_snippet_array(file, line)
            snp = []
            if File.file?(file)
              source = source(file)
              radius = 2 # TODO: make customizable (number of surrounding lines to show)
              region = [line - radius, 1].max ..
                       [line + radius, source.length].min
              snp = region.map do |n|
                [n, source[n-1].chomp]
              end
            end
            return snp
          end

          # Cache source file text. This is only used if the TAP-Y stream
          # doesn not provide a snippet and the test file is locatable.
          def source(file)
            @_source_cache[file] ||= (
              File.readlines(file)
            )
          end

          # Parse source location from caller, caller[0] or an Exception object.
          def parse_source_location(caller)
            case caller
            when Exception
              trace  = caller.backtrace.reject{ |bt| bt =~ INTERNALS }
              caller = trace.first
            when Array
              caller = caller.first
            end
            caller =~ /(.+?):(\d+(?=:|\z))/ or return ""
            source_file, source_line = $1, $2.to_i
            return source_file, source_line
          end

          # Get location of exception.
          def location(backtrace)
            last_before_assertion = ""
            backtrace.reverse_each do |s|
              break if s =~ /in .(assert|refute|flunk|pass|fail|raise|must|wont)/
              last_before_assertion = s
            end
            file, line = last_before_assertion.sub(/:in .*$/, '').split(':')
            line = line.to_i if line
            return file, line
          end

          #
          def clean_message(message)
            message.strip.gsub(/\n+/, "\n")
          end

          #
          def puts(string='')
            @output.write(string.chomp+"\n")
            @output.flush
          end

          # Create fake stdio and stderr streams and capture the ouputs. Backup the original stdout and stderr
          def capture_output
            @_oldout = $stdout
            @_olderr = $stderr

            @_newout = StringIO.new
            @_newerr = StringIO.new

            $stdout = @_newout
            $stderr = @_newerr
          end

          # Restore original stdout and stderr. Return the captured output as a string
          def reset_output
            stdout = @_newout.string.chomp("\n")
            stderr = @_newerr.string.chomp("\n")

            doc = ""
            doc << stdout unless stdout.empty?
            doc << stderr unless stdout.empty?
            $stdout = @_oldout
            $stderr = @_olderr

            return doc
          end

        end

      end #module Html
    end #module UI
  end #module Unit
end #module Test
