class PledgesController < ApplicationController
  
  before_action :load_campaign, only: [:create]
  before_action :load_pledge, only: [:create]
  
  def create
    if @pledge.save
      flash[:notice] = t '.success'
    else
      flash[:error] = t '.error'
    end
    redirect_to @campaign
  end
  
  def load_pledge
    authorize @campaign, :show?
    @pledge = Pledge.new(campaign: @campaign, attendee: current_attendee, amount_cents: params.require(:pledge)[:amount_cents])
    authorize @pledge
  end
  
end
