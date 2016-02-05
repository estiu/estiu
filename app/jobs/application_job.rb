class ApplicationJob < ActiveJob::Base
  
  ESTIU_JOB_CLASSES = Set.new
  
  include Rollbar::ActiveJob
  
  def self.inherited(subclass)
    ESTIU_JOB_CLASSES << subclass
    subclass.queue_as format_queue_name(subclass.name.to_s.underscore)
  end
  
  def self.format_queue_name name, env=Rails.env
    # format MUST start by rails env, so `queue_name_prefix` works in AwsOps::SQS.drain_all_queues.
    "#{env}-#{name.gsub('/', '-')}"
  end
  
end