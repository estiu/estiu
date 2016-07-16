class DashboardController < ApplicationController
  
  before_action :load_campaigns, only: [:index]
  before_action :load_events, only: [:index]
  
  def index
    authorize DashboardPolicy
  end
  
  protected
  
  def load_campaigns
    @campaigns = DashboardPolicy::Scope.new(current_user, campaign_listing_scope).resolve
  end
  
  def load_events
    @events = DashboardPolicy::Scope.new(current_user, event_listing_scope).resolve
  end
  
  def campaign_listing_scope
    Campaign.without_event
  end
  
  def event_listing_scope
    Event
  end
  
end