module Permit
  class Policy
    include Enumerable
    attr_reader :rules

    def initialize(opts={})
      @resource_id = opts[:resource_id]
      @rules = []
      @producer = opts[:producer]
    end

    def add(rule)
      subject_id = rule[:subject_id]
      actions = rule[:action].respond_to?(:each) ? rule[:action] : [rule[:action]]

      if i = index_of(subject_id)
        actions.each do |a|
          @rules[i][:actions][a.to_sym] = true
        end
      else
        init = { :subject_id => subject_id, :actions => {} }
        new_rule = actions.inject(init) do |acc, a|
          acc[:actions][a.to_sym] = true
          acc
        end
        @rules << new_rule
      end
    end

    def remove(opts)
      subject_id = opts[:subject_id]
      filter = {
        :action => []
      }.merge(opts)
      actions = filter[:action].respond_to?(:each) ? filter[:action] : [filter[:action]]

      return nil unless index_of(subject_id)
      return delete_rule(subject_id) if actions.length == 0


      rule_idx = index_of(subject_id)
      actions.each do |a|
        @rules[rule_idx][:actions].delete(a.to_sym)
      end
      delete_rule(subject_id) if @rules[rule_idx][:actions].empty?
    end

    def commit
      @producer.publish(self)
    end

    def each(&block)
      @rules.each do |rule|
        rule[:resource_id] = @resource_id
        block.call(rule)
      end
    end

    protected

    def index_of(subject_id)
      @rules.index { |r| r[:subject_id] == subject_id }
    end

    def delete_rule(subject_id)
      if i = index_of(subject_id)
        @rules.delete_at(i)
      end
    end
  end
end
