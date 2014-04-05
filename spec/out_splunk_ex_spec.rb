# encoding: UTF-8
require_relative 'spec_helper'
require 'benchmark'
Fluent::Test.setup

def create_driver(config, tag = 'foo.bar')
  Fluent::Test::OutputTestDriver.new(Fluent::SplunkExOutput, tag).configure(config)
end

# setup
single_key_message = {
  'msg' => 'testing some data'
}

multi_key_message = {
  'msg'            => 'testing some data',
  'chars'          => 'let"s put !@#$%^&*()-= some weird :\'?><,./ characters',
  'dt'             => '2014/04/03T07:02:11.124202',
  'debug_line'     => 24,
  'debug_file'     => '/some/path/to/myFile.py',
  'statsd_key'     => 'fluent_plugin_splunk_ex',
  'statsd_timing'  => 0.234,
  'statsd_type'    => 'timing',
  'tx'             => '280c3e80-bb6c-11e3-a5e2-0800200c9a66',
  'host'           => 'my01.cool.server.com'
}

time = Time.now.to_i

driver_kv = create_driver(%[
  log_level     fatal
  test_mode     true
  output_format kv
])

driver_json = create_driver(%[
  log_level     fatal
  test_mode     true
  output_format json
])

driver_kv_time = create_driver(%[
  log_level fatal
  test_mode true
  output_format kv
  time_key myKey
  include_time_key true
])

driver_json_time = create_driver(%[
  log_level fatal
  test_mode true
  output_format json
  time_key myKey
  include_time_key true
])



# bench
n = 10000
Benchmark.bm(7) do |x|
  x.report("single_kv       ") { driver_kv.run        { n.times { driver_kv.emit(       single_key_message, time) } } }
  x.report("single_kv_time  ") { driver_kv_time.run   { n.times { driver_kv_time.emit(  single_key_message, time) } } }
  x.report("single_json     ") { driver_json.run      { n.times { driver_json.emit(     single_key_message, time) } } }
  x.report("single_json_time") { driver_json_time.run { n.times { driver_json_time.emit(single_key_message, time) } } }

  x.report("multi_kv        ") { driver_kv.run        { n.times { driver_kv.emit(       multi_key_message, time ) } } }
  x.report("multi_kv_time   ") { driver_kv_time.run   { n.times { driver_kv_time.emit(  multi_key_message, time ) } } }
  x.report("multi_json      ") { driver_json.run      { n.times { driver_json.emit(     multi_key_message, time ) } } }
  x.report("multi_json_time ") { driver_json_time.run { n.times { driver_json_time.emit(multi_key_message, time ) } } }

end

