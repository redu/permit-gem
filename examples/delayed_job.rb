require "rubygems"
require "bundler/setup"
require "permit"

opts = { :resource_id => "core:course_1", :service_name => "core" }
job = Permit::PolicyJob.new(opts) do |policy|
  policy.add(:subject_id => "core:user_1", :action => :read)
end
