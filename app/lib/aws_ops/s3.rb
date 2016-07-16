class AwsOps::S3
  
  extend AwsOps
  
  def self.update_env_files
    Dir.glob(".env*").each do |filename|
      s3_client.put_object bucket: 'events-env-vars', key: filename, body: File.open(filename).read, acl: 'private', server_side_encryption: 'AES256'
    end
  end
  
  # NOTE: uploads buckets must have a CORS config such as the following:
  # ----------
  # <CORSConfiguration>
  #   <CORSRule>
  #       <AllowedOrigin>*</AllowedOrigin>
  #       <AllowedMethod>GET</AllowedMethod>
  #       <MaxAgeSeconds>3000</MaxAgeSeconds>
  #       <AllowedHeader>*</AllowedHeader>
  #   </CORSRule>
  #   <CORSRule>
  #       <AllowedOrigin>*</AllowedOrigin>
  #       <AllowedMethod>POST</AllowedMethod>
  #       <MaxAgeSeconds>3000</MaxAgeSeconds>
  #       <AllowedHeader>*</AllowedHeader>
  #   </CORSRule>
  #   <CORSRule>
  #       <AllowedOrigin>*</AllowedOrigin>
  #       <AllowedMethod>PUT</AllowedMethod>
  #       <MaxAgeSeconds>3000</MaxAgeSeconds>
  #       <AllowedHeader>*</AllowedHeader>
  #   </CORSRule>
  # </CORSConfiguration>

  
end