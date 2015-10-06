class ApplicationController < ActionController::Base
  
  protect_from_forgery with: :exception
  
  def flash_content key, object
    (object = object.errors.full_messages) if key == :error
    target = key == :error ? flash.now : flash
    Array(object).each{|err|
      target[key] ||= []
      target[key] << err
    }
  end
  
  def date_format
    Date::DATE_FORMATS[:default]
  end
  
  def datetime_format
    Time::DATE_FORMATS[:default]
  end
  
end
