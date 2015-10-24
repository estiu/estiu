class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  
  def facebook
    uid = auth_hash[:uid]
    email = auth_hash[:info][:email]
    first_name = auth_hash[:info][:first_name]
    last_name = auth_hash[:info][:last_name]
    fb_attrs = {
      facebook_user_id: uid,
      facebook_access_token: auth_hash[:credentials][:token],
      facebook_access_token_expires: Time.at(auth_hash[:credentials][:expires_at].to_i).to_datetime,
    }
    if current_user
      current_user.update_attributes!(fb_attrs)
    else
      user = User.find_or_create_from_facebook_assigning_token email, first_name, last_name, fb_attrs
      if user.save
        sign_in user
      else
        logger.error "Couldn't sign up user via facebook. Errors: #{user.errors}"
      end
    end
    redirect_to after_sign_in_path_for(current_user)
  end
  
  protected
  
  def auth_hash
    request.env['omniauth.auth']
  end
  
end