require "rubygems"
require "bundler/setup"
require "permit/mechanism"

mechanism = Permit::Mechanism.new(:host => "http://0.0.0.0:9000", :service_name => "wally", :subject_id => "core:user_4")
puts mechanism.able_to?(:read, "core:space_1")
