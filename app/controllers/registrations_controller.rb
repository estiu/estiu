class RegistrationsController < Devise::RegistrationsController
  
  def sign_up_params
    additional = params.
      require(:user).
      permit(attendee_attributes: %i(first_name last_name entity_type_shown_at_signup entity_id_shown_at_signup)).
      merge(role: Roles.attendee)
    super.merge(additional)
  end
  
  def after_sign_up_path_for resource
    attendee_common_path resource, super
  end
  
  def after_inactive_sign_up_path_for resource
    attendee_common_path resource, super
  end
  
  def attendee_common_path resource, alternative
    if Causality.checking?("RegistrationsController#attendee_common_path")
      alternative
    else
      resource.attendee.after_sign_up_path
    end
  end
  
end 