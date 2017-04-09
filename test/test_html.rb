# encoding: UTF-8

# TODO: When run through rake test, the relative path of files change in the ouput and it fails. Need to fix that.
require 'stringio'
require File.expand_path(File.dirname(__FILE__) + '/../lib/test/unit/ui/html/html_runner.rb')
require File.expand_path(File.dirname(__FILE__) + '/fixtures/test_example.rb')
class TestHtml < Test::Unit::TestCase
  def test_run
    ## not used: fail_line = nil
    # test_case = Class.new(Test::Unit::TestCase) do
    #   def test_success
    #     assert_equal(3, 1 + 2)
    #   end

    #   def test_fail; assert_equal(3, 1 - 2); end; fail_line = __LINE__
    # end
    output = StringIO.new
    runner = Test::Unit::UI::Html::HtmlTestRunner.new(TestExample.suite, :output => output)
    result = runner.start
    ## not used: start_line = __LINE__
    assert_equal(<<-EOR, output.string.gsub(/Time Taken : [\d\.]+/, "Time Taken : 0.001").gsub(/Test Started at (.*?)<\/h1>/, 'Test Started at today</h1>'))
<html>
<head>
<title> Test Results</title>
</head>
<body>
<h1> Now executing test suite : TestExample</h1>
<h1> Total number of tests : 2</h1>
<h1> Test Started at today</h1>

<br>
   Test name : test_add(TestExample), Result : Passed
  <br>
  Captured Output : 

<br>
<hr>
<br>
  Test name : test_subtract(TestExample), Result : Failed

  <br>
  Captured Output : 

<br>
 Message : <code> Should have subtracted correctly.
&lt;4&gt; expected but was
&lt;3&gt;. </code>
<br>
 Class : Test::Unit::Failure
<br>
  Line : 15
<br>
  Source :
  <br>
  <code> assert_equal(4, @number - 2, &quot;Should have subtracted correctly&quot;) </code>
<br>
  snippet :
  <br>
  <code>
      13 
   14   def test_subtract
=&gt; 15     assert_equal(4, @number - 2, &quot;Should have subtracted correctly&quot;)
   16   end
   17 
  </code>
<br>
  backtrace :
 <br>
<code> test/fixtures/test_example.rb:15test/test_html.rb:19 </code>
<hr>
<br>
<br>
<h1>Test Suite Ended. Time Taken : 0.001
<br>
Total tests : 2
<br>
Passed : 1
<br>
Failed : 1
</h1>
EOR
    assert_false(result.passed?)    # think this is correct, where as original runner had it wrong
  end
end

