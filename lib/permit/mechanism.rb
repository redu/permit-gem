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

    # Queries the server side component for the rules of some resource for
    # the specified subject.
    #
    #   mech = Permit::Mechanism.new(:subject_id => "core:user_1")
    #   mech.able_to?(:read, "core:course_2")
    #   => true
    #
    # The Mechanism also takes into accout the actions precedence. For example
    # when the subject is enabled to manage some resource, asking for reading
    # rights the result is true. This behaivor may be bypassed using the
    # argument :strict => true
    def able_to?(action, resource, opts={})
      if opts[:strict]
        response = head(:action => action, :resource_id => resource)
        response.status == 200
      else
        response = get(:resource_id => resource)
        return false unless response.success?
        data = JSON.parse(response.body, :symbolize_keys => true)

        if rule = data[0]
          if %w(read create destroy index update).include?(action.to_s)
            return rule[:actions][:manage] == true
          else
            return rule[:actions][action] == true
          end
        end
      end
    end

    def head(opts)
      params = opts.merge({:subject_id => @config[:subject_id]})
      connection.head("/rules", params)
    end

    def get(opts)
      params = opts.merge({:subject_id => @config[:subject_id]})
      connection.get("/rules", params)
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
