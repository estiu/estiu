class SessionsController < Devise::SessionsController
  
  def new
    r = request.referrer
    store_location_for(:user, request.referrer) if r && !r.include?('sign_in')
    super
  end
  
end
