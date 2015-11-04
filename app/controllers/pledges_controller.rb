class PledgesController < ApplicationController
  
  before_action :load_campaign, only: [:create, :update]
  before_action :authorize_campaign, only: [:create, :update]
  before_action :new_pledge, only: [:create]
  before_action :load_pledge, only: [:update]
  
  def create
    @pledge.calculate_total!
    if @pledge.save
      render json: {
        id: @pledge.id,
        amount_cents: @pledge.amount_cents,
        discounted_message: @pledge.discounted_message}
    else
      flash.now[:error] = @pledge.errors.full_messages
      render json: flash_json, status: 422
    end
  end
  
  def update
    stripe_token = params.require :stripeToken
    if @pledge.charge!(stripe_token)
      render(json: {
        pledge_contribution_content: render_to_string(partial: 'pledges/contributed', locals: {campaign: @campaign, pledge: @pledge}),
        campaign_fulfilled_percent: @campaign.percent_pledged,
        campaign_fulfilled_caption: I18n.t('campaigns.show.percent', percent: @campaign.percent_pledged),
        campaign_pledged_title: I18n.t('campaigns.show.title', pledged: @campaign.pledged.format)
      })
    else
      flash.now[:error] = t '.error'
      render json: flash_json, status: 422
    end
  end
  
  def authorize_campaign
    authorize @campaign, :show?
  end
  
  def new_pledge
    @pledge = Pledge.new(
      campaign: @campaign,
      attendee: current_attendee,
      originally_pledged_cents: params.require(:pledge).require(:originally_pledged_cents),
      referral_email: params.require(:pledge)[:referral_email],
      desired_credit_ids: (params.require(:pledge)[:desired_credit_ids] || []) # ids are validated at model level. this includes consumed or extraneous ids.
    )
    authorize @pledge
  end
  
  def load_pledge
    @pledge = Pledge.unscoped.where(attendee_id: current_attendee.id).find(params[:pledge_id])
    authorize @pledge
  end
  
end
