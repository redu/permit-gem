require "faraday"

module Permit
  class Mechanism
    def initialize(opts)
      @config = {
        :host => "http://permit.redu.com.br",
        :service_name => "",
        :subject_id => ""
      }.merge(opts)
    end

    def able_to?(action, resource)
      response = head(:action => action, :resource_id => resource)
      response.status == 200
    end

    def head(opts)
      params = opts.merge({:subject_id => @config[:subject_id]})
      connection.head("/rules", params)
    end

    protected

    def connection
      @connection ||= Faraday.new(:url => @config[:host]) do |faraday|
        faraday.request  :url_encoded
        # faraday.response :logger
        faraday.adapter  :patron
        faraday.headers = {'Accept' => 'application/json'}
      end
    end
  end
end
