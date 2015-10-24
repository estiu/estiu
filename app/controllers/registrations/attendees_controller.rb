class Registrations::AttendeesController < Devise::RegistrationsController
  
  def new
    store_location_for(:user, request.referrer) if request.referrer
    super
  end
  
  def sign_up_params
    additional = params.
      require(:user).
      permit(attendee_attributes: %i(first_name last_name)).
      merge(roles: [Roles.attendee])
    super.merge(additional)
  end
  
end 