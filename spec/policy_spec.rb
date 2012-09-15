require 'spec_helper'

module Permit
  describe Policy do
    it "should be initialized with a resource" do
      Policy.new(:resource_id => "r").should be_a Policy
    end
    it "should respond to #add" do
      Policy.new(:resource_id => "r").should respond_to :add
    end
    it "should increment rules" do
      p = Policy.new(:resource_id => "r")
      expect {
        p.add(:subject_id => "s", :action => :a)
      }.to change(p.instance_variable_get(:@rules), :length).by(1)
    end

    it "should add the rules" do
      p = Policy.new(:resource_id => "r")
      rule = { :subject_id => "s", :action => :a }
      p.add(rule)

      rules = p.instance_variable_get(:@rules)
      rules.should include rule
    end

    it "should accept a list of actions" do
      p = Policy.new(:resource_id => "r")
      rule = { :subject_id => "s", :action => [:a1, :a2] }
      expect {
        p.add(rule)
      }.to change(p.instance_variable_get(:@rules), :length).by(2)
    end

    it "should respond to #remove" do
      Policy.new(:resource_id => "r").should respond_to :remove
    end

    it "should remove rules passing the subject" do
      p = Policy.new(:resource_id => "r")
      rule = { :subject_id => "s", :action => [:a1, :a2] }
      p.add(rule)
      p.add(:subject_id => "t", :action => :a1)

      expect {
        p.remove(:subject_id => "s")
      }.to change(p.instance_variable_get(:@rules), :length).by(-2)
    end

    it "should remove the rules passing the subject and action" do
      p = Policy.new(:resource_id => "r")
      rule = { :subject_id => "s", :action => [:a1, :a2] }
      p.add(rule)
      p.add(:subject_id => "t", :action => :a1)

      p.remove(:subject_id => "s", :action => :a1)
      rules = p.instance_variable_get(:@rules)

      rules.should_not include({ :subject_id => "s", :action => :a1 })
    end

    it "should not remove all the rules when passing specific action" do
      p = Policy.new(:resource_id => "r")
      rule = { :subject_id => "s", :action => [:a1, :a2] }
      p.add(rule)
      p.add(:subject_id => "t", :action => :a1)

      p.remove(:subject_id => "s", :action => :a1)
      rules = p.instance_variable_get(:@rules)

      rules.should include({ :subject_id => "s", :action => :a2 })
    end

    it "should remove the rules passing a list of actions" do
      p = Policy.new(:resource_id => "r")
      rule = { :subject_id => "s", :action => [:a1, :a2] }
      p.add(rule)
      p.add(:subject_id => "t", :action => :a1)

      expect {
        p.remove(:subject_id => "s", :actions => [:a1, :a2])
      }.to change(p.instance_variable_get(:@rules), :length).by(-2)
    end

    it "should respond to #commit"
    it "should commit rules"
  end
end
