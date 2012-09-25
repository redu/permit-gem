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

    context "strict request" do
      let(:host) do
        "http://permit.redu.com.br/rules?action=read&resource_id=r" + \
          "&subject_id=s"
      end
      before do
        stub_request(:head, host).
          with(:headers => {'Accept'=>'application/json', 'Expect'=>''}).
          to_return(:status => 200)
      end

      it "should generate an HEAD request with the correct params" do
        response = subject.head(:resource_id => "r", :action => :read)
        response.status.should == 200
      end

      it "should allow access when response code is 200" do
        subject.should be_able_to(:read, "r", :strict => true)
      end

      it "should not allow access when response code is 404" do
        stub_request(:head, host).to_return(:status => 404, :body => "")
        subject.should_not be_able_to(:read, "r", :strict => true)
      end
    end

    context "non strict request" do
      before do
        h = "http://permit.redu.com.br/rules?resource_id=r&subject_id=s"
        resp = [{ :id => "2", :subject_id => "s", :resource_id => "r",
                  :actions => { :manage => true, :foo => true } }].to_json
        stub_request(:get, h).
          with(:headers => {'Accept'=>'application/json'}).
          to_return(:status => 200, :body => resp,
                    :headers => { 'Contet-type' => 'application/json' })
      end

      %w(read create destroy index update manage).each do |action|
        it "should respect the precedence of manage over #{action}" do
          subject.should be_able_to(action.to_sym, "r")
        end
      end

      it "should work for custom actions" do
        subject.should be_able_to(:foo, "r")
      end

      it "should not allow access when the action is not specified" do
        subject.should_not be_able_to(:preview, "r")
      end

      it "should not allow access when the HTTP status is 404" do
        host = "http://permit.redu.com.br/rules?resource_id=r&subject_id=s"
        stub_request(:get, host).
          with(:headers => {'Accept'=>'application/json'}).
          to_return(:status => 404)

        subject.should_not be_able_to(:read, "r")
      end

      it "should not allow access when the response is empty" do
        h = "http://permit.redu.com.br/rules?resource_id=r&subject_id=s"
        stub_request(:get, h).
          with(:headers => {'Accept'=>'application/json'}).
          to_return(:status => 200, :body => [].to_json,
                    :headers => { 'Contet-type' => 'application/json' })

        subject.should_not be_able_to(:read, "r")
      end
    end
  end
end
