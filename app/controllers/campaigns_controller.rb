class CampaignsController < ApplicationController
  
  before_action :load_campaign, only: [:show]
  before_action :authorize_campaign, only: [:show]
  
  def index
    authorize(@campaigns = Campaign.all)
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
      flash_content(:success, t('.success'))
      redirect_to @campaign
    else
      flash_content(:error, t('.error'))
      render :new
    end
  end
  
  protected

  def campaign_attrs
    v = params.permit(campaign: Campaign::CREATE_ATTRS)[:campaign]
    process_datetime_params v, Campaign::DATE_ATTRS
  end
  
  def authorize_campaign
    authorize @campaign
  end
  
end
