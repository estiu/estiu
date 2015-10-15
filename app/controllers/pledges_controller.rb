class PledgesController < ApplicationController
  
  before_action :load_campaign, only: [:create]
  before_action :load_pledge, only: [:create]
  
  def create
    redirect_to :back
  end
  
  def load_pledge
    authorize @campaign, :show?
    @pledge = Pledge.new(campaign: @campaign)
    authorize @pledge
  end
  
end
