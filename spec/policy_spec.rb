require 'spec_helper'

module Permit
  describe Policy do
    subject { Policy.new(:resource_id => "r") }
    it "should be initialized with a resource" do
      subject.should be_a Policy
    end

    context "#add" do
      it "should respond to #add" do
        subject.should respond_to :add
      end

      it "should increment rules event list" do
        subject
        expect {
          subject.add(:subject_id => "s", :action => :a)
        }.to change(subject.rules_events, :length).by(1)
      end

      it "should add the rules" do
        rule = { :subject_id => "s", :action => :a }
        subject.add(rule)

        rules = subject.rules_events
        rules.last.name.should == :create
        rules.last.payload.should == \
          { :resource_id => "r", :subject_id => "s", :actions => { :a => true } }
      end

      it "should accept a list of actions" do
        subject
        rule = { :subject_id => "s", :action => [:a1, :a2] }
        expect {
          subject.add(rule)
        }.to change(subject.rules_events, :length).by(1)
      end

      it "should raise error when adding a rule without an action" do
        expect {
          subject.add({:subject_id => "s"})
        }.to raise_error
      end
    end

    context "#remove" do
      it "should respond to #remove" do
        subject.should respond_to :remove
      end

      it "should remove rules passing the subject" do
        rule = { :subject_id => "s", :action => [:a1, :a2] }
        subject.add(rule)
        subject.add(:subject_id => "t", :action => :a1)

        subject.remove(:subject_id => "s")
        subject.rules_events.length.should == 3
        subject.rules_events.last.name == :remove
      end

      it "should remove the rules passing the subject and action" do
        rule = { :subject_id => "s", :action => [:a1, :a2] }
        subject.add(rule)
        subject.add(:subject_id => "t", :action => :a1)

        subject.remove(:subject_id => "s", :action => :a1)
        rules = subject.rules_events

        rules.should_not include({ :subject_id => "s", :action => :a1 })
      end

      it "should remove the rules passing a list of actions" do
        rule = { :subject_id => "s", :action => [:a1, :a2] }
        subject.add(rule)
        subject.add(:subject_id => "t", :action => :a1)

        expect {
          subject.remove(:subject_id => "s", :actions => [:a1, :a2])
        }.to change(subject.rules_events, :length).by(1)
      end

    end

    context "#commit" do
      it "should respond to #commit" do
        Policy.new(:resource_id => "r").should respond_to :commit
      end

      it "should commit rules" do
        producer = double('Producer')
        producer.stub(:publish) { |policy| nil }
        p = Policy.new(:resource_id => "r", :producer => producer)
        p.add({ :subject_id => "s", :action => :a })
        p.remove({ :subject_id => "s", :action => :a })

        producer.should_receive(:publish).with(p).twice
        p.commit
      end
    end

    it "should be iterable" do
      subject.add(:subject_id => "s1", :action => [:a1, :a2])
      subject.add(:subject_id => "s2", :action => [:a2])

      subject.to_a.to_set == subject.rules_events.to_set
    end
  end
end
