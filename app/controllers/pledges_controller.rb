class PledgesController < ApplicationController
  
  before_action :authorize_campaign
  before_action :load_pledge, only: %i(update charge refund_payment create_refund_credit)
  
  def update
    @pledge.assign_attributes(
      originally_pledged_cents: params.require(:pledge).require(:originally_pledged_cents),
      referral_email: params.require(:pledge)[:referral_email],
      desired_credit_ids: (params.require(:pledge)[:desired_credit_ids] || []) # ids are validated at model level. this includes consumed or extraneous ids.
    )
    @pledge.calculate_total!
    if @pledge.save
      render json: {
        id: @pledge.id,
        amount_cents: @pledge.amount_cents,
        amount_cents_formatted: @pledge.amount.format,
        discounted_message: (@pledge.discount_cents.zero? ? nil : @pledge.discount.format)}
    else
      flash.now[:error] = @pledge.errors.full_messages
      render json: flash_json, status: 422
    end
  end
  
  def charge
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
  
  %i(refund_payment create_refund_credit).each do |method|
    define_method method do
      refund_common "#{method}!"
    end
  end
  
  protected
  
  def refund_common method
    if @pledge.send(method)
      flash[:success] = t '.success', amount: @pledge.amount.format
    else
      flash[:error] = t '.error'
    end
    redirect_to @campaign
  end
  
  def authorize_campaign
    load_campaign
    authorize @campaign, :show?
  end
  
  def load_pledge
    @pledge = Pledge.unscoped.where(attendee_id: current_attendee.id).find(params[:pledge_id])
    authorize @pledge
  end
  
end
