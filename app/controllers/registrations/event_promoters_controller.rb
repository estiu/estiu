class Registrations::EventPromotersController < Devise::RegistrationsController
  
  def sign_up_params
    additional = params.require(:user).permit(event_promoter_attributes: %i(name email website)).merge(roles: [Roles.event_promoter])
    super.merge(additional)
  end
  
end
