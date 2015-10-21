class SessionsController < Devise::SessionsController
  
  def new
    store_location_for(:user, request.referrer) unless params[:controller] == 'sessions'
    super
  end
  
end
