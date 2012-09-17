require 'spec_helper'

module Permit
  describe Mechanism do
    let(:subject) do
      Mechanism.new(:subject_id => "s", :service_name => "wally")
    end

    it "should be instaciable with resource and service name" do
      Mechanism.new(:subject_id => "core:users_1", :service_name => "wally").
        should be_a Mechanism
    end

    it "should respond to able_to?" do
      subject.should respond_to :able_to?
    end

    it "should generate an HEAD request with the correct params" do
      stub_request(:head, "http://permit.redu.com.br/rules?action=read&resource_id=r").
        to_return(:status => 200, :body => "", :headers => {})

      response = subject.head(:resource_id => "r", :action => :read)
      response.status.should == 200
    end

    it "should allow access when response code is 200" do
      stub_request(:head, "http://permit.redu.com.br/rules?action=read&resource_id=r").
        to_return(:status => 200, :body => "", :headers => {})

      subject.should be_able_to(:read, "r")
    end

    it "should not allow access when response code is 404" do
      stub_request(:head, "http://permit.redu.com.br/rules?action=read&resource_id=r").
        to_return(:status => 404, :body => "", :headers => {})

      subject.should_not be_able_to(:read, "r")
    end
  end
end
