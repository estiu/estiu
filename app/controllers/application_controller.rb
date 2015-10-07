class ApplicationController < ActionController::Base
  
  protect_from_forgery with: :exception
  
  def flash_content key, object
    target = key == :error ? flash.now : flash
    Array(object).each{|err|
      target[key] ||= []
      target[key] << err
    }
  end
  
  helper_method :date_format
  def date_format
    Date::DATE_FORMATS[:default]
  end
  
  helper_method :datetime_format
  def datetime_format
    Time::DATE_FORMATS[:default]
  end
  
  def process_datetime_params hash, attrs
    if hash
      attrs.map do |attr|
        the_date = hash[attr].present? ? Date.strptime(hash[attr], date_format) : Date.today
        hash["#{attr}_not_given"] = hash[attr].blank?
        hash["#{attr}(1i)"] = the_date.year.to_s
        hash["#{attr}(2i)"] = the_date.month.to_s
        hash["#{attr}(3i)"] = the_date.day.to_s
        (4..5).each do |n|
          hash["#{attr}_#{n}i"] = hash["#{attr}(#{n}i)"]
        end
      end
    end
    hash
  end
  
end
