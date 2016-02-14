CarrierWave.configure do |config|
  
  credential_options = DeveloperMachine.running_in_developer_machine? ?
    AwsOps::Infrastructure.credentials.except(:access_key_id, :secret_access_key) :
    { use_iam_profile: true }
    
  config.fog_credentials = {
    provider: 'AWS',
    region: AwsOps::Infrastructure.region
  }.merge(credential_options)
  
  config.fog_directory = AwsOps::UPLOADS_BUCKET
  config.validate_unique_filename = false
  config.max_file_size 20.megabytes
  config.use_action_status = true
  config.upload_expiration = 30.days # avoid hard-to-reproduce issue (https://github.com/dwilkie/carrierwave_direct/issues/191 )
  
end