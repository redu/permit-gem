module Permit
  class Config
    def self.logger=(logger)
      @@logger = logger
    end
    def self.logger
      @@logger ||= Logger.new(STDOUT)
    end
  end
end
