class CalculationsController < ApplicationController
  
  FORMAT_OPTS = {no_cents_if_whole: false}.freeze
  
  before_action :authorize_calculation
  
  # applies taxes and commissions (taxes not implemented yet).
  def calculate_goal_cents
    campaign = CampaignDraft.new(proposed_goal_cents: params.require(:proposed_goal_cents))
    campaign.generate_goal_cents
    value = campaign.goal.format(FORMAT_OPTS.dup)
    render json: {value: value}
  end
  
  protected
  
  def authorize_calculation
    authorize CalculationsPolicy
  end
  
end