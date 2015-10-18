class PledgesController < ApplicationController
  
  before_action :load_campaign, only: [:create, :update]
  before_action :authorize_campaign, only: [:create, :update]
  before_action :new_pledge, only: [:create]
  before_action :load_pledge, only: [:update]
  
  def create
    if @pledge.save
      render json: {id: @pledge.id}
    else
      flash.now[:error] = t '.error'
      render json: flash_json, status: 422
    end
  end
  
  def update
    stripe_token = params.require :stripeToken
    if @pledge.charge!(stripe_token)
      render(json: {
        pledge_contribution_content: render_to_string(partial: 'pledges/contributed', locals: {campaign: @campaign})
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
    @pledge = Pledge.new(campaign: @campaign, attendee: current_attendee, amount_cents: params.require(:pledge).require(:amount_cents))
    authorize @pledge
  end
  
  def load_pledge
    @pledge = Pledge.unscoped.where(attendee_id: current_attendee.id).find(params[:pledge_id])
    authorize @pledge
  end
  
end
