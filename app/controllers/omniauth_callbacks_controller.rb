class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  
  def facebook
    # @user = User.from_omniauth(auth_hash)
    # if @user.persisted?
    #   sign_in @user
    #   flash[:message] = ...
    # else
    #   session["devise.facebook_data"] = request.env["omniauth.auth"]
    #   redirect_to new_user_registration_url
    # end
    redirect_to after_sign_in_path_for(current_user)
  end
  
  protected
  
  def auth_hash
    request.env['omniauth.auth']
  end
  
end
