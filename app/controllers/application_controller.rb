class ApplicationController < ActionController::Base
  
  include Pundit
  
  protect_from_forgery with: :exception
  
  before_action :ensure_modern_browser
  after_action :verify_authorized, unless: :devise_controller?
  
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActionController::ParameterMissing, with: :param_required
  
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
          user_given = hash["#{attr}(#{n}i)"]
          if user_given # set the attr_accessor fields, as defined in ResettableDates
            hash["#{attr}_#{n}i"] = user_given
          else # set the Rails time fields (note the extra parenses in "#{attr}(#{n}i)")
            hash["#{attr}(#{n}i)"] = DateTime.now.send({4 => :hour, 5 => :minute}[n]).to_s
          end
        end
      end
    end
    hash
  end
  
  def user_not_authorized *e
    logger.info e if dev_or_test?
    flash[:alert] = t('application.forbidden')
    handle_unauthorized
  end
  
  def param_required *e
    logger.info e if dev_or_test?
    flash[:alert] = t('application.param_required')
    handle_unauthorized
  end
  
  def handle_unauthorized
    if request.xhr?
      render json: flash_json, status: 403
    else
      redirect_to(request.referrer || root_path)
    end
  end
  
  def load_campaign
    @campaign = Campaign.find(params[:id])
  end
  
  helper_method :current_attendee
  def current_attendee
    current_user.try :attendee
  end
  
  def flash_json
    {flash_content: render_to_string(partial: 'layouts/flash_messages')}
  end
  
  def after_sign_in_path_for(resource)
    request.env['omniauth.origin'] || stored_location_for(:user) || root_path
  end
  
  def after_sign_out_path_for(resource_or_scope)
    request.referrer || root_path
  end
  
  def ensure_modern_browser
    unless Rails.env.test?
      unless browser.modern?
        flash[:error] = t 'application.modern_browser_required'
        redirect_to page_path(id: 'home')
      end
    end
  end
  
end
