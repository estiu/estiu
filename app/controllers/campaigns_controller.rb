class CampaignsController < ApplicationController
  
  before_action :load_campaign, only: :show
  
  def index
    authorize(@campaigns = Campaign.all)
  end
  
  def show
    authorize @campaign
  end
  
  def new
    authorize(@campaign = Campaign.new)
  end
  
  def create
    authorize(@campaign = Campaign.new(campaign_attrs))
    @campaign.event_promoter = EventPromoter.first || FG.create(:event_promoter)
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
  
  def load_campaign
    @campaign = Campaign.find(params[:id])
  end
  
end
