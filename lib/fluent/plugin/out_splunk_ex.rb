require 'open-uri'
require 'json'

class Fluent::SplunkExOutput < Fluent::Output

  SOCKET_TRY_MAX = 3

  Fluent::Plugin.register_output('splunk_ex', self)

  include Fluent::SetTagKeyMixin
  config_set_default :include_tag_key, false

  include Fluent::SetTimeKeyMixin
  config_set_default :include_time_key, false

  config_param :host, :string, :default => 'localhost'
  config_param :port, :string, :default => 9997
  config_param :output_format, :string, :default => 'json'

  config_param :test_mode, :bool, :default => false

  # To support log_level option implemented by Fluentd v0.10.43
  unless method_defined?(:log)
    define_method(:log) { $log }
  end


  def configure(conf)
    super
  end

  def start
    super

    if @output_format == 'kv'
      @format_fn = self.class.method(:format_kv)
    else
      @format_fn = self.class.method(:format_json)
    end

    if @test_mode
      @send_data = proc { |text| log.trace("test mode text: #{text}") }
    else
      begin
        @splunk_connection = TCPSocket.open(@host, @port)
      rescue Errno::ECONNREFUSED
        # we'll try again when data is sent
      end
      @send_data = self.method(:splunk_send)
    end

  end


  def shutdown
    super
    if !@test_mode && @splunk_connection.respond_to?(:close)
      @splunk_connection.close
    end
  end


  def emit(tag, es, chain)
    chain.next
    es.each {|time,record|
      @send_data.call( @format_fn.call(record) )
    }
  end

  # =================================================================

  protected

  def self.format_kv(record)
    kv_out_str = ''
    record.each { |k, v|
      kv_out_str << sprintf('%s=%s ', URI::encode(k), URI::encode(v.to_s))
    }
    kv_out_str
  end

  def self.format_json(record)
    json_str = record.to_json
  end

  def splunk_send(text, try_count=0)
    log.debug("splunk_send: #{text}")

    successful_send = false
    try_count = 0

    while (!successful_send && try_count < SOCKET_TRY_MAX)
      begin
        @splunk_connection.puts(text)
        successful_send = true

      rescue NoMethodError, Errno::ECONNRESET, Errno::ECONNREFUSED, Errno::EPIPE => se
        log.error("splunk_send - socket send retry (#{try_count}) failed: #{se}")
        try_count = try_count + 1

        successful_reopen = false
        while (!successful_reopen && try_count < SOCKET_TRY_MAX)
          begin
            # Try reopening
            @splunk_connection = TCPSocket.open(@host, @port)
            successful_reopen = true
          rescue Errno::ECONNRESET, Errno::ECONNREFUSED, Errno::EPIPE => se
            log.error("splunk_send - socket open retry (#{try_count}) failed: #{se}")
            try_count = try_count + 1
          end
        end
      end
    end

    if !successful_send
      log.fatal("splunk_send - retry of sending data failed after #{SOCKET_TRY_MAX} chances.")
      log.warn(text)
    end
    
  end


end

