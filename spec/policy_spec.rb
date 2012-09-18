require 'spec_helper'

module Permit
  describe Policy do
    subject { Policy.new(:resource_id => "r") }
    it "should be initialized with a resource" do
      subject.should be_a Policy
    end

    it "should respond to #add" do
      subject.should respond_to :add
    end

    it "should increment rules" do
      subject
      expect {
        subject.add(:subject_id => "s", :action => :a)
      }.to change(subject.rules, :length).by(1)
    end

    it "should add the rules" do
      rule = { :subject_id => "s", :action => :a }
      subject.add(rule)

      rules = subject.rules
      rules.should include({ :subject_id => 's', :actions => { :a => true } })
    end

    it "should accept a list of actions" do
      subject
      rule = { :subject_id => "s", :action => [:a1, :a2] }
      expect {
        subject.add(rule)
      }.to change(subject.rules, :length).by(1)
    end

    it "should respond to #remove" do
      subject.should respond_to :remove
    end

    it "should remove rules passing the subject" do
      rule = { :subject_id => "s", :action => [:a1, :a2] }
      subject.add(rule)
      subject.add(:subject_id => "t", :action => :a1)

      expect {
        subject.remove(:subject_id => "s")
      }.to change(subject.rules, :length).by(-1)
    end

    it "should remove the rules passing the subject and action" do
      rule = { :subject_id => "s", :action => [:a1, :a2] }
      subject.add(rule)
      subject.add(:subject_id => "t", :action => :a1)

      subject.remove(:subject_id => "s", :action => :a1)
      rules = subject.rules

      rules.should_not include({ :subject_id => "s", :action => :a1 })
    end

    it "should not remove all the rules when passing specific action" do
      rule = { :subject_id => "s", :action => [:a1, :a2] }
      subject.add(rule)
      subject.add(:subject_id => "t", :action => :a1)

      subject.remove(:subject_id => "s", :action => :a1)
      rules = subject.rules

      rules.should include({ :subject_id => "s", :actions => {:a2 => true} })
    end

    it "should remove the rules passing a list of actions" do
      rule = { :subject_id => "s", :action => [:a1, :a2] }
      subject.add(rule)
      subject.add(:subject_id => "t", :action => :a1)

      expect {
        subject.remove(:subject_id => "s", :actions => [:a1, :a2])
      }.to change(subject.rules, :length).by(-1)
    end

    it "should respond to #commit" do
      Policy.new(:resource_id => "r").should respond_to :commit
    end

    it "should commit rules" do
      producer = double('Producer')
      producer.stub(:publish) { |policy| nil }
      p = Policy.new(:resource_id => "r", :producer => producer)
      p.add({ :subject_id => "s", :action => :a })

      producer.should_receive(:publish).with(p)
      p.commit
    end

    it "should be iterable" do
      subject.add(:subject_id => "s1", :action => [:a1, :a2])
      subject.add(:subject_id => "s2", :action => [:a2])

      rules = [ {:subject_id => "s", :resource_id => "r1", :actions => { :a1 => true, :a2 => true }},
                {:subject_id => "s", :resource_id => "r1", :actions => { :a2 => true } } ]

      subject.to_a.collect(&:to_set) == rules.to_a.collect(&:to_set)
    end
  end
end
