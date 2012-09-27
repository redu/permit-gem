module Permit
  class Policy
    include Enumerable
    attr_reader :rules_events

    def initialize(opts={})
      @resource_id = opts[:resource_id]
      @rules_events = []
      @producer = opts[:producer]
    end

    # Schedules a rule to be created.
    #
    # policy.add(:subject_id => 's', :action => :read)
    # policy.add(:subject_id => 's2, :action => [:read, :preview])
    def add(rule=nil, &block)
      if block_given?
        yield(self)
        self.commit
      else
        unless rule[:action]
          raise  "When adding rules you need to pass, at least, one action: " + \
                 "#{rule.inspect}"
        end

        @rules_events << setup_event(:create, rule)
      end
    end

    # Schedules the removal of one rule
    #
    # policy.remove(:subject_id => 's') # removes all rules from s
    # policy.remove(:subject_id => 's', :action => :read) # removes the read rights
    def remove(opts=nil, &block)
      if block_given?
        yield(self)
        self.commit
      else
        @rules_events << setup_event(:remove, opts)
      end
    end

    def commit
      @rules_events.collect do |event|
        @producer.publish event
      end
    end

    def each(&block)
      @rules_events.each do |rule|
        block.call(rule)
      end
    end

    protected

    def setup_event(event_name, rule)
      basic_rule = { :resource_id => @resource_id, :subject_id => rule[:subject_id] }

      if action = rule[:action]
        actions = action.respond_to?(:each) ? action : [action]
        basic_rule[:actions] = {}
        basic_rule = actions.reduce(basic_rule) do |acc, a|
          acc[:actions][a.to_sym] = true
          acc
        end
      end

      Event.new(:name => event_name, :payload => basic_rule)
    end
  end
end
