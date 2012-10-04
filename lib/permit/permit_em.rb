require 'amqp/utilities/event_loop_helper'

module Permit
  def self.start
    AMQP::Utilities::EventLoopHelper.run do
      AMQP.start
    end

    EventMachine.next_tick do
      AMQP.channel ||= AMQP::Channel.new(AMQP.connection)
    end
  end
end
