require 'yajl/json_gem'
require 'amqp'

module Permit
  class Producer
    def initialize(opts={})
      @routing_key = "permit.#{opts.delete(:service_name)}"
      @opts = {}
      @connection = opts[:connection]
      check_running_conditions

      @channel = opts[:channel] || AMQP::Channel.new(@connection)
      @exchange = opts[:exchange] || @channel.topic("permit",
                                                    :auto_delete => true)
    end

    def publish(event)
      e = { :name => event.name, :payload => event.payload }
      @exchange.publish(e.to_json, :routing_key => @routing_key)
    end

    protected

    def check_running_conditions
      if !@connection
        raise "In order to produce events you need to pass an AMQP connection"
      elsif !defined?(EventMachine) && !EM.reactor_running?
        raise "In order to use the producer you must be running inside an " + \
              "eventmachine loop"
      end
    end
  end
end
