require "rubygems"
require "bundler/setup"
require "permit"

EM.run do
  AMQP.connect do |connection|
    producer = Permit::Producer.new(:service_name => 'wally', :connection => connection)
    policy = Permit::Policy.new(:resource_id => 'core:user_1', :producer => producer)
    policy.add(:subject_id => 'core:user_2', :action => :preview)
    policy.add(:subject_id => 'core:user_3', :action => :preview)
    policy.add(:subject_id => 'core:user_4', :action => :preview)
    policy.commit
  end
end
