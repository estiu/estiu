class ApplicationController < ActionController::Base
  
  include Pundit
  
  protect_from_forgery with: :exception
  
  after_action :verify_authorized, unless: :devise_controller?
  
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  
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
  
  def user_not_authorized *_
    flash[:alert] = t('application.forbidden')
    redirect_to(request.referrer || root_path)
  end
  
  def load_campaign
    @campaign = Campaign.find(params[:id])
  end
  
end
