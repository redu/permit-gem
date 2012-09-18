module Permit
  class Event
    attr_reader :name, :payload
    def initialize(opts)
      @payload = opts[:payload]
      @name = opts[:payload]
    end
  end
end
