class VenuesController < ApplicationController
  
  def create
    authorize Venue
    venue = Venue.new venue_params.except(OBJECT_FOR_FORM_KEY)
    if venue.save
      render 'venues/create_successful', locals: {selected_id: venue.id, object_for_form: object_for_form}, layout: false, status: 200
    else
      flash.now[:error] = t '.error'
      render 'layouts/flash_messages_js', layout: false, status: 422
    end
  end
  
  protected
  
  OBJECT_FOR_FORM_KEY = 'object_for_form'
  OBJECT_FOR_FORM_HASH = Hash.new{ raise }
  
  def venue_params
    params.require(:venue).permit(Venue::CREATE_ATTRS + [OBJECT_FOR_FORM_KEY])
  end
  
  def object_for_form
    OBJECT_FOR_FORM_HASH.merge("event" => Event.new, "campaign_draft" => CampaignDraft.new) # this merge must be done at runtime, else suite fails
    OBJECT_FOR_FORM_HASH[venue_params.require(OBJECT_FOR_FORM_KEY)]
  end
  
end
