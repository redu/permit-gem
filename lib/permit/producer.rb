require 'yajl/json_gem'
require 'amqp'

module Permit
  class Producer
    def initialize(opts={})
      @routing_key = "permit.#{opts.delete(:service_name)}"
      @opts = {}

      if AMQP.channel
        Config.logger.info "Using defined AMQP.channel"
        check_em_reactor
        @channel = AMQP.channel
        @exchange = @channel.topic("permit", :auto_delete => true)
      else
        Config.logger.info "Setting up new connection and channel"
        @connection = opts[:connection]
        check_em_reactor
        check_amqp_connection
        @channel = opts[:channel] || AMQP::Channel.new(@connection)
        @exchange = opts[:exchange] || @channel.topic("permit",
                                                      :auto_delete => true)
      end
    end

    def publish(event)
      e = { :name => event.name, :payload => event.payload }
      Config.logger.info \
        "Publishing event #{e.inspect} with routing key #{@routing_key}"
      EM.next_tick do
        @exchange.publish(e.to_json, :routing_key => @routing_key)
      end
    end

    protected

    def check_amqp_connection
      if !@connection
        raise "In order to produce events you need to pass an AMQP connection"
      end
    end

    def check_em_reactor
      if !defined?(EventMachine) && !EM.reactor_running?
        raise "In order to use the producer you must be running inside an " + \
              "eventmachine loop"
      end
    end
  end
end
