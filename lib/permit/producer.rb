require 'yajl/json_gem'
require 'amqp'

module Permit
  class Producer
    def initialize(opts={})
      @opts = {
        :service_name => Permit.config.service_name,
        :deliver_messages => Permit.config.deliver_messages,
        :channel => nil,
      }.merge(opts)

      @routing_key = "permit.#{@opts[:service_name]}"

      if !@opts[:deliver_messages]
        Permit.config.logger.info \
          "AMQP.channel was not setted up because message delivering is disabled."
        return
      end

      check_em_reactor

      if AMQP.channel || @opts[:channel]
        Permit.config.logger.info "Using defined AMQP.channel"
        @channel = AMQP.channel || @opts[:channel]
        @exchange = @channel.topic("permit", :auto_delete => true)
      end
    end

    def publish(event)
      event = { :name => event.name, :payload => event.payload }
      safe_publish(event)
    end

    protected

    def safe_publish(e)
      if @opts[:deliver_messages]
        @exchange.publish(e.to_json, :routing_key => @routing_key) do
          Permit.config.logger.info \
            "Publishing event #{e.inspect} with routing key #{@routing_key}"
        end
      else
        Permit.config.logger.info \
          "The event #{ e.inspect} was not delivered. Try to set " + \
          "Permit.config.deliver_messages to true"
      end
    end

    def check_em_reactor
      if !defined?(EventMachine) || !EM.reactor_running?
        raise "In order to use the producer you must be running inside an " + \
              "eventmachine loop"
      end
    end
  end
end
