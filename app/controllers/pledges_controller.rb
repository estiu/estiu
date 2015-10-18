class PledgesController < ApplicationController
  
  before_action :load_campaign, only: [:create]
  before_action :load_pledge, only: [:create]
  
  def create
    stripe_token = params.require :stripeToken
    if @pledge.create_by_charging(stripe_token)
      render json: {
        pledge_contribution_content: render_to_string(partial: 'pledges/contributed', locals: {campaign: @campaign})
      }.merge(flash_json)
    else
      flash.now[:error] = t '.error'
      render json: flash_json
    end
  end
  
  def load_pledge
    authorize @campaign, :show?
    @pledge = Pledge.new(campaign: @campaign, attendee: current_attendee, amount_cents: @campaign.recommended_pledge_amount_cents)
    authorize @pledge
  end
  
end
