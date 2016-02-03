class AwsOps::SQS
  
  extend AwsOps
  
  def self.drain_all_queues! # XXX should query by environment
    sqs_client.list_queues.queue_urls.each do |url|
      begin
        sqs_client.purge_queue queue_url: url
      rescue Aws::SQS::Errors::PurgeQueueInProgress => e
        puts "AwsOps::SQS - Sleeping..."
        sleep 61
        retry
      end
    end
  end
  
end