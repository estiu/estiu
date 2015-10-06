class CampaignsController < ApplicationController
  
  before_action :load_campaign, only: :show
  
  def index
    @campaigns = Campaign.all
  end
  
  def show
  end
  
  def new
    @campaign = Campaign.new
  end
  
  def create
    @campaign = Campaign.new(campaign_attrs)
    @campaign.event_promoter = EventPromoter.first || FG.create(:event_promoter)
    if @campaign.save
      flash_content(:success, t('.success'))
      redirect_to @campaign
    else
      flash_content(:error, @campaign)
      render :new
    end
  end
  
  protected
  
  def campaign_attrs
    v = params.permit(campaign: Campaign::CREATE_ATTRS)[:campaign]
    if v
      %i(starts_at ends_at).map do |attr|
        v[attr] = Date.strptime(v[attr], date_format) if v[attr].present?
      end
    end
    v
  end
  
  def load_campaign
    @campaign = Campaign.find(params[:id])
  end
  
end
