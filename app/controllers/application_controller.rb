class ApplicationController < ActionController::Base
  
  include Pundit
  
  protect_from_forgery with: :exception
  
  before_action :ensure_modern_browser
  before_action :prepare_campaign_notification_value
  before_action :prepare_event_notification_value
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
  
  def process_datetime_params hash, attrs, time_zone
    if hash
      attrs.map do |attr|
        the_date = hash[attr].present? ? Date.strptime(hash[attr], date_format) : DateTime.current.to_date # XXX Date.strptime -> Estiu::Timezones::ALL_TIMEZONE_OBJECTS[time_zone].strptime. Depends on Rails 5
        hash["#{attr}_not_given"] = hash[attr].blank?
        hash["#{attr}(1i)"] = the_date.year.to_s
        hash["#{attr}(2i)"] = the_date.month.to_s
        hash["#{attr}(3i)"] = the_date.day.to_s
        (4..5).each do |n|
          user_given = hash["#{attr}(#{n}i)"]
          if user_given # set the attr_accessor fields, as defined in ResettableDates
            hash["#{attr}_#{n}i"] = user_given
          else # set the Rails time fields (note the extra parenses in "#{attr}(#{n}i)")
            hash["#{attr}(#{n}i)"] = DateTime.current.in_time_zone(time_zone).send({4 => :hour, 5 => :minute}[n]).to_s
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
    @campaign.passed_invite_token = params[:invite_token]
  end
  
  Roles.all.each do |role|
    
    helper_method "current_#{role}".to_sym
    define_method "current_#{role}" do
      key = "@current_#{role}_cache".to_sym
      value = instance_variable_get(key)
      if value != nil # use cached `false` values
        value
      else
        if role == Roles.admin 
          value = current_user.admin? ? current_user : false
        else
          value = current_user.try role
        end
        instance_variable_set(key, value)
        value
      end
    end
    
  end
  
  def flash_json
    {flash_content: render_to_string(partial: 'layouts/flash_messages')}
  end
  
  def after_sign_in_path_for(resource)
    value = stored_location_for(:user) || request.env['omniauth.origin']
    if !value || value.include?('sign_in') || value.include?('sign_up')
      root_path
    else
      value
    end
  end
  
  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
  
  def ensure_modern_browser
    unless Rails.env.test?
      unless browser.modern?
        flash[:error] = t 'application.modern_browser_required'
        redirect_to page_path(id: 'home')
      end
    end
  end
  
  def ensure_ajax_uploading
    if browser.ie? || browser.opera?
      flash[:error] = t 'application.ensure_ajax_uploading'
      redirect_to root_path
    end
  end
  
  helper_method :public_home_page?
  def public_home_page?
    (params[:controller] == 'pages' && params[:id] == 'home') ||
    (params[:controller] == 'application' && params[:action] == 'home')
  end
  
  def home
    skip_authorization
    if current_user
      redirect_to (current_event_promoter ? mine_campaigns_path : campaigns_path)
    else
      if Rails.env.development?
        redirect_to new_user_session_path
      else
        render 'pages/home'
      end
    end
  end
  
  def prepare_campaign_notification_value
    cache_key = "prepare_campaign_notification_value_#{current_user.try(:id)}"
    @campaign_notification_value = if current_event_promoter
      0
    elsif current_attendee
      Rails.cache.fetch(cache_key, notification_cache_options){
        Campaign.visible_for_attendee(current_attendee).fulfilled.without_event.count
      }
    else
      0
    end
  end
  
  def prepare_event_notification_value
    cache_key = "prepare_event_notification_value_#{current_user.try(:id)}"
    @event_notification_value = if current_event_promoter
      Rails.cache.fetch(cache_key, notification_cache_options){
        Campaign.visible_for_event_promoter(current_event_promoter).without_event.count
      }
    elsif current_attendee
      Rails.cache.fetch(cache_key, notification_cache_options){
        Event.visible_for_attendee(current_attendee).not_celebrated.count
      }
    else
      0
    end
  end
  
  def notification_cache_options
    {expires_in: (dev_or_test? ? 0 : 90).seconds}
  end
  
  def initialize_uploader
    ensure_ajax_uploading
    @uploader = MountedUploader.new.uploader
    @uploader.success_action_status = '201'
  end
  
end
