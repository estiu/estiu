CarrierWave.configure do |config|
  
  credential_options = (if DeveloperMachine.running_in_developer_machine?
      c = AwsOps::Permanent.credentials
      {aws_access_key_id: c[:access_key_id], aws_secret_access_key: c[:secret_access_key]}
    else
      { use_iam_profile: true }
    end)
    
  config.fog_credentials = {
    provider: 'AWS',
    region: AwsOps::Permanent.region
  }.merge(credential_options)
  
  config.fog_directory = AwsOps::UPLOADS_BUCKET
  config.validate_unique_filename = false
  config.max_file_size 20.megabytes
  config.use_action_status = true
  config.upload_expiration = 30.days # avoid hard-to-reproduce issue (https://github.com/dwilkie/carrierwave_direct/issues/191 )
  
end