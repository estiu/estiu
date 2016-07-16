class DashboardController < ApplicationController
  
  before_action :authorize_dashboard, only: [:index]
  before_action :load_campaigns, only: [:index]
  before_action :load_events, only: [:index]
  
  def index
  end
  
  protected
  
  def authorize_dashboard
    authorize DashboardPolicy
  end
  
  def load_campaigns
    @campaigns = DashboardPolicy::Scope.new(current_user, campaign_listing_scope).resolve
  end
  
  def load_events
    @events = DashboardPolicy::Scope.new(current_user, event_listing_scope).resolve
  end
  
  def campaign_listing_scope
    Campaign.joins(:campaign_draft).includes(campaign_draft: :event_promoter).without_event
  end
  
  def event_listing_scope
    Event.includes(campaign: {campaign_draft: :event_promoter})
  end
  
end