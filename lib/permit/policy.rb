module Permit
  class Policy
    def initialize(opts)
      @resource_id = opts[:resource_id]
      @rules = []
    end

    def add(rule)
      subject_id = rule[:subject_id]
      actions = rule[:action].respond_to?(:each) ? rule[:action] : [rule[:action]]

      actions.each do |a|
        @rules << { :subject_id => subject_id, :action => a }
      end
    end

    def remove(opts)
      filter = {
        :action => []
      }.merge(opts)
      actions = filter[:action].respond_to?(:each) ? filter[:action] : [filter[:action]]

      @rules = @rules.delete_if do |r|
        if actions.size > 0
          r[:subject_id] == filter[:subject_id] && actions.include?(r[:action])
        else
          r[:subject_id] == filter[:subject_id]
        end
      end
    end
  end
end
