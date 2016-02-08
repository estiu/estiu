class CampaignsController < ApplicationController
  
  should_load_campaign = [:show, :edit, :update, :view_draft, :destroy, :submit]
  before_action :load_campaign, only: should_load_campaign
  before_action :authorize_campaign, only: should_load_campaign
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
  
  # after campaign approval, this endpoint is still useful: it shows the information with which the Campaign was submitted (which has more fields than shown at campaigns#show)
  def view_draft
  end
  
  def edit
  end
  
  def new
    authorize(@campaign = Campaign.new)
  end
  
  def create
    authorize(@campaign = Campaign.new(campaign_attrs_step_1))
    @campaign.event_promoter = current_user.event_promoter
    if @campaign.save
      redirect_to view_draft_campaign_path(@campaign)
    else
      flash.now[:error] = t('.error')
      render :new
    end
  end
  
  def update
    @campaign.assign_attributes(campaign_attrs_step_1)
    if @campaign.save
      redirect_to view_draft_campaign_path(@campaign), notice: t('.success')
    else
      flash.now[:error] = t('.error')
      render :edit
    end
  end
  
  def submit
    @campaign.assign_attributes(campaign_attrs_step_2)
    @campaign.submitted_at = DateTime.now
    if @campaign.save
      flash.now[:success] = t('.success')
    else
      flash.now[:error] = t('.error')
    end
    render :view_draft
  end
  
  def destroy
    verify_authorized # extra call just in case
    if @campaign.destroy
      flash[:success] = t('.success')
    else
      flash[:error] = t('.error')
    end
    redirect_to campaigns_path
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
    Campaign.approved.without_event
  end
  
  def campaign_attrs_step_1
    authorize(Campaign.new) unless @campaign.try(:id) # ugly extra call to .authorize for keeping the tests happy
    params.permit(campaign: Campaign::CREATE_ATTRS_STEP_1)[:campaign]
  end
  
  def campaign_attrs_step_2
    v = params.permit(campaign: Campaign::CREATE_ATTRS_STEP_2)[:campaign]
    if v[:time_zone].present?
      process_datetime_params v, Campaign::DATE_ATTRS, v[:time_zone]
    else
      v.except(:"starts_at(4i)", :"starts_at(5i)", :"ends_at(4i)", :"ends_at(5i)")
    end
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
