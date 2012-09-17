require 'yajl/json_gem'
require 'amqp'

module Permit
  class Producer
    def initialize(opts={})
      @routing_key = "permit.#{opts.delete(:service_name)}"
      @opts = opts || {}
    end

    def publish(policy)
      EventMachine.run do
        AMQP.connect do |connection|
          channel  = AMQP::Channel.new(connection)
          exchange = channel.topic("permit", :auto_delete => true)

          policy.each do |rule|
            puts rule.inspect
            exchange.publish(rule.to_json, :routing_key => @routing_key)
          end
        end

      end
    end
  end
end
