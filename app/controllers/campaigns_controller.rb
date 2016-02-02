class CampaignsController < ApplicationController
  
  before_action :load_campaign, only: [:show]
  before_action :authorize_campaign, only: [:show]
  before_action :ensure_pledge, only: [:show]
  
  def index
    authorize Campaign
    @campaigns = policy_scope listing_scope
  end
  
  def mine
    authorize Campaign
    scope = listing_scope
    @campaigns = (
      if current_event_promoter
        scope.visible_for_event_promoter current_event_promoter
      elsif current_attendee
        scope.visible_for_attendee current_attendee
      else
        policy_scope scope
      end
    )
    render 'index'
  end
  
  def show
  end
  
  def new
    authorize(@campaign = Campaign.new)
  end
  
  def create
    authorize(@campaign = Campaign.new(campaign_attrs))
    @campaign.event_promoter = current_user.event_promoter
    if @campaign.save
      flash[:success] = t('.success')
      redirect_to @campaign
    else
      flash.now[:error] = t('.error')
      render :new
    end
  end
  
  helper_method :in_mine_page?
  def in_mine_page?
    params[:action] == 'mine'
  end
  
  helper_method :should_create_event?
  def should_create_event?
    (@campaign.event_promoter == current_event_promoter) && @campaign.fulfilled_at && !@campaign.event
  end
  
  protected
  
  def listing_scope
    Campaign.without_event
  end
  
  def campaign_attrs
    authorize(Campaign.new) # ugly extra call to .authorize for keeping the tests happy
    Campaign::DATE_ATTRS.each{|attr| params.require(:campaign).require attr }
    v = params.permit(campaign: Campaign::CREATE_ATTRS)[:campaign]
    process_datetime_params v, Campaign::DATE_ATTRS
  end
  
  def authorize_campaign
    authorize @campaign
  end
  
  def ensure_pledge
    if current_attendee
      @pledge = Pledge.unscoped.where(attendee: current_attendee, campaign: @campaign).first_or_initialize
      unless @pledge.originally_pledged_cents
        @pledge.originally_pledged_cents ||= @campaign.minimum_pledge_cents
        @pledge.calculate_total!
        @pledge.save!
      end
    end 
  end
  
end
