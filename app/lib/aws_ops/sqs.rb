class AwsOps::SQS
  
  extend AwsOps
  
  def self.drain_all_queues! # XXX should query by environment
    sqs_client.list_queues.queue_urls.each do |url|
      sqs_client.purge_queue queue_url: url
    end
  end
  
end