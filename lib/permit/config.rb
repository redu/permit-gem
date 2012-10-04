module Permit
  def self.configure(&block)
    yield(config) if block_given?

    if config.deliver_messages
      Permit.start
    end
  end

  def self.config
    @config ||= Config.new
  end

  class Config
    include Configurable

    config :logger, Logger.new(STDOUT)
    config :deliver_messages, true
    config :mechanism_host,  "http://permit.redu.com.br"
    config :service_name
  end
end
