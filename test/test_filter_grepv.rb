require_relative '../helper'
require 'fluent/plugin/filter_grepv'

class GrepvFilterTest < Test::Unit::TestCase
  include Fluent

  setup do
    Fluent::Test.setup
    @time = Fluent::Engine.now
  end

  def create_driver(conf = '')
    Test::FilterTestDriver.new(GrepvFilter).configure(conf, true)
  end

  sub_test_case 'configure' do
    test 'check default' do
      d = create_driver
      assert_empty(d.instance.regexps)
      assert_empty(d.instance.excludes)
    end

    test "regexpN can contain a space" do
      d = create_driver(%[regexp1 message  foo])
      assert_equal(Regexp.compile(/ foo/), d.instance.regexps['message'])
    end

    test "excludeN can contain a space" do
      d = create_driver(%[exclude1 message  foo])
      assert_equal(Regexp.compile(/ foo/), d.instance.excludes['message'])
    end
  end

  sub_test_case 'filter_stream' do
    def messages
      [
        {'level' => "INFO", 'method' => "GET", 'path' => "/ping"},
        {'level' => "WARN", 'method' => "POST", 'path' => "/auth"},
        {'level' => "WARN", 'method' => "GET", 'path' => "/favicon.ico"},
        {'level' => "WARN", 'method' => "POST", 'path' => "/login"},
      ]
    end

    def emit(config, msgs)
      d = create_driver(config)
      d.run {
        msgs.each { |msg|
          d.emit(msg, @time)
        }
      }.filtered
    end

    test 'empty config' do
      es = emit('', messages)
      assert_equal(4, es.instance_variable_get(:@record_array).size)
    end

    test 'regexpN' do
      es = emit('regexp1 level WARN', messages)
      assert_equal(1, es.instance_variable_get(:@record_array).size)
      assert_block('no WARN logs') do
        es.all? { |t, r|
          !r['level'].include?('WARN')
        }
      end
    end

    test 'excludeN' do
      config = %[regexp1 level WARN\nexclude1 path favicon]
      es = emit(config, messages)
      assert_equal(2, es.instance_variable_get(:@record_array).size)
    end

    sub_test_case 'with invalid sequence' do
      def messages
        [
          "\xff".force_encoding('UTF-8'),
        ]
      end

      test "don't raise an exception" do
        assert_nothing_raised { 
          emit(%[regexp1 message WARN], ["\xff".force_encoding('UTF-8')])
        }
      end
    end
  end
end
