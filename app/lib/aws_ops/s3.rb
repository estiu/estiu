class AwsOps::S3
  
  extend AwsOps
  
  def self.update_env_files
    Dir.glob(".env*").each do |filename|
      s3_client.put_object bucket: 'events-env-vars', key: filename, body: File.open(filename).read, acl: 'private', server_side_encryption: 'AES256'
    end
  end
  
end