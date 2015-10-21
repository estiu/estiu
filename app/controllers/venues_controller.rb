class VenuesController < ApplicationController
  
  def create
    venue = Venue.new venue_params
    if venue.save
      render json: {id: venue.id}
    else
      flash[:error] = t '.error'
      render json: flash_json, status: 422
    end
  end
  
  protected
  
  def venue_params
    params.require(:venue).permit(Venue::CREATE_ATTRS)
  end
  
end
