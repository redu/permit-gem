require 'spec_helper'

module Permit
  describe Producer do
    it "should initilize producer" do
      setup_em do |c|
        Producer.new(:service_name => 'foo', :connection => c).
          should be_a Producer
      end
    end

    it "should raise RuntimeError when trying to run without the reactor" do
      expect {
        Producer.new(:service_name => 'foo')
      }.to raise_error
    end

    it "should raise RuntimeError if EM is not running" do
      setup_em do |connection|
        EM.stub("reactor_running?" => false)
        expect {
          Producer.new(:service_name => 'foo')
        }.to raise_error
      end
    end

    it "should publish event" do
      e = Event.new(:name => "create", :payload => { :foo => 'bar' })
      setup_em do |c|
        exchange = double('Exchange')
        exchange.should_receive(:publish)

        producer = Producer.new(:service_name => 'foo', :connection => c,
                                :exchange => exchange)
        producer.publish(e)
      end
    end

    def setup_em
      EM.run do
        AMQP.connect do |c|
          yield(c)
          EM.stop
        end
      end
    end
  end
end
