require 'amqp'

module PermitEM
  def self.start
    # faciliates debugging
    Thread.abort_on_exception = true
    # just spawn a thread and start it up
    Thread.new do
      EM.run do
        AMQP.connect do |c|
          EM.next_tick do
            AMQP.channel ||= AMQP::Channel.new(c)
          end
        end
      end
    end
  end
end
