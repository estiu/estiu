class VenuesController < ApplicationController
  
  def create
    authorize Venue
    venue = Venue.new venue_params
    if venue.save
      render 'venues/create_successful', locals: {selected_id: venue.id}, layout: false, status: 200
    else
      flash.now[:error] = t '.error'
      render 'layouts/flash_messages_js', layout: false, status: 422
    end
  end
  
  protected
  
  def venue_params
    params.require(:venue).permit(Venue::CREATE_ATTRS)
  end
  
end
