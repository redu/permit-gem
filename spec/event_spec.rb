require 'spec_helper'

module Permit
  describe Event do
    let(:event) do
      Event.new(:name => "create", :payload => { :foo => "bar" })
    end

    it "should be initializable with a name and payload" do
      event.should be_a Event
    end

    it "should hold the name" do
      event.name.should == "create"
    end

    it "should hold the payload" do
      event.payload.should == { :foo => "bar" }
    end
  end
end
