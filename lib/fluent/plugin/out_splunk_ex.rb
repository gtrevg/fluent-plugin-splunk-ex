require 'open-uri'
require 'json'

class Fluent::SplunkExOutput < Fluent::Output
  Fluent::Plugin.register_output('splunk_ex', self)

  config_param :host, :string, :default => 'localhost'
  config_param :port, :string, :default => 9997
  config_param :format, :string, :default => 'kv'
  config_param :use_time, :bool, :default => false
  config_param :time_key, :string, :default => 'time'

  config_param :test_mode, :bool, :default => false

  # To support log_level option implemented by Fluentd v0.10.43
  unless method_defined?(:log)
    define_method("log") { $log }
  end

  def configure(conf)
    super
  end

  def start
    super

    if @format != 'json'
      @format_fn = self.class.method(:format_kv)
    else
      @format_fn = self.class.method(:format_json)
    end

    @format_fn.call({"more" => "stuff"})

    if test_mode
      @send_data = proc {|text| log.info("test mode text: #{text}") }
    else
      @splunk_connection = TCPSocket.open(@host, @port)
      @send_data = self.class.splunk_send
    end
  end


  def shutdown
    super
    if !test_mode
      @splunk_connection.close
    end
  end


  def emit(tag, es, chain)
    chain.next
    es.each {|time,record|
      if @use_time
        record.merge!({@time_key => Time.at(time).to_datetime.to_s})
      end

      @send_data.call( @format_fn.call(record) )
    }
  end

  # =================================================================

  protected

  def self.format_kv(record)
    kv_out_arr = []
    record.each { |k, v|
      kv_out_arr << sprintf('%s=%s', URI::encode(k), URI::encode(v.to_s))
    }

    kv_out_str = kv_out_arr.join(' ')
  end

  def self.format_json(record)
    json_str = record.to_json
  end

  def self.splunk_send(text)
    log.debug("splunk text: #{text}")
    @splunk_connection.puts(text)
  end


end

