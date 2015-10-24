class SessionsController < Devise::SessionsController
  
  def new
    store_location_for(:user, request.referrer) if request.referrer
    super
  end
  
end
