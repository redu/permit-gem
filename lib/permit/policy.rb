module Permit
  class Policy
    include Enumerable
    attr_reader :rules_events

    def initialize(opts={})
      @resource_id = opts[:resource_id]
      @rules_events = []
      @producer = opts[:producer]
    end

    def add(rule)
      subject_id = rule[:subject_id]
      actions = rule[:action].respond_to?(:each) ? rule[:action] : [rule[:action]]

      new_rule = { :resource_id => @resource_id,
                   :subject_id => subject_id, :actions => {} }
      new_rule = actions.reduce(new_rule) do |acc, a|
        acc[:actions][a.to_sym] = true
        acc
      end

      @rules_events << Event.new(:name => "create", :payload => new_rule)
    end

    def remove(opts)
      subject_id = opts[:subject_id]
      new_rule = if action = opts[:action]
        actions = action.respond_to?(:each) ? action : [action]

        new_rule = { :resource_id => @resource_id,
                     :subject_id => subject_id, :actions => {} }
        actions.reduce(new_rule) do |acc, a|
          acc[:actions][a.to_sym] = true
          acc
        end
      else
       { :resource_id => @resource_id, :subject_id => subject_id }
      end

      @rules_events << Event.new(:name => "remove", :payload => new_rule)
    end

    def commit
      @rules_events.each do |event|
        @producer.publish(self)
      end
    end

    def each(&block)
      @rules_events.each do |rule|
        block.call(rule)
      end
    end
  end
end
