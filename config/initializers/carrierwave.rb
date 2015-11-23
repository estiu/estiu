CarrierWave.configure do |config|
  
  credential_options = Rails.env.production? ?
    { use_iam_profile: true } :
    {
      aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    }
    
  config.fog_credentials = {
    provider: 'AWS',
    region: ENV['AWS_REGION']
  }.merge(credential_options)
  
  config.fog_directory = AwsOps::UPLOADS_BUCKET
  config.validate_unique_filename = false
  config.max_file_size 20.megabytes
  
end