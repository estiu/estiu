class RegistrationsController < Devise::RegistrationsController
  
  def sign_up_params
    additional = params.require(:user).permit(attendee_attributes: [:first_name, :last_name]).merge(role: Roles.attendee)
    super.merge(additional)
  end
  
end 