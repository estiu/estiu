class CalculationsController < ApplicationController
  
  before_action :authorize_calculation
  
  # applies taxes and commissions (taxes not implemented yet).
  def calculate_goal_cents
    campaign = CampaignDraft.new(proposed_goal_cents: params.require(:proposed_goal_cents))
    render json: campaign.present_calculations
  end
  
  protected
  
  def authorize_calculation
    authorize CalculationsPolicy
  end
  
end