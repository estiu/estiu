# I never want to mount uploaders in my models - so we can use a generic 'mounted uploader' ready to use whenever a S3 upload is needed.
class MountedUploader
  
  extend CarrierWave::Mount
  
  attr_accessor :uploader
  mount_uploader :uploader, BaseUploader
  
end
