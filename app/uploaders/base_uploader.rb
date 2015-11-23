class BaseUploader < CarrierWave::Uploader::Base
  
  include CarrierWaveDirect::Uploader
  
  def extension_white_list
    %w(pdf)
  end
  
  def errors
    {}
  end
  
end
