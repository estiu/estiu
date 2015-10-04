class ApplicationController < ActionController::Base
  
  protect_from_forgery with: :exception
  
  def flash_content key, object
    if key == :error
      object.errors.full_messages.each{|err|
        flash.now[key] ||= []
        flash.now[key] << err
      }
    end
  end
  
end
