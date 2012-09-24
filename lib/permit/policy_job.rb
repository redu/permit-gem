module Permit
  class PolicyJob
    # job = PolicyJob.new(:resource_id => 'core:course_12') do |policy|
    #   policy.add(:subject_id => 'core:user_1', :read => true)
    # end
    #
    # DelayedJob.enqueue job
    def initialize(opts, &block)
      @service_name = opts.delete(:service_name)
      @resource_id = opts.delete(:resource_id)
      @callback = block
    end

    def perform
      producer = Producer.new(:service_name => @service_name)
      policy = Policy.new(:resource_id => @resource_id, :producer => producer)
      @callback.call(policy)
      policy.commit
    end
  end
end
