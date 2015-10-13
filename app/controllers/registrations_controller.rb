class RegistrationsController < Devise::RegistrationsController
  
  def sign_up_params
    additional = params.require(:user).permit(attendee_attributes: [:first_name, :last_name]).merge(role: Roles.attendee)
    devise_parameter_sanitizer.sanitize(:sign_up).merge(additional)
  end
  
end 