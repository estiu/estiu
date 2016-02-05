class AwsOps::SQS
  
  extend AwsOps
  
  def self.drain_all_queues!
    sqs_client.list_queues(queue_name_prefix: environment).queue_urls.each do |url|
      begin
        sqs_client.purge_queue queue_url: url
      rescue Aws::SQS::Errors::PurgeQueueInProgress => e
        puts "AwsOps::SQS - Sleeping..."
        sleep 61
        retry
      end
    end
  end
  
  def self.ensure_queues_created
    YAML.load(ERB.new(IO.read(Rails.root + 'config' + 'shoryuken.yml')).result).deep_symbolize_keys.fetch(:queues).map(&:first).each do |queue|
      sqs_client.create_queue(queue_name: queue)
    end
  end
  
end