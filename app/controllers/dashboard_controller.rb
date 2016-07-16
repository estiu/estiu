class DashboardController < ApplicationController
  
  before_action :load_campaigns, only: [:index]
  
  def index
  end
  
  protected
  
  def load_campaigns
    authorize DashboardPolicy
    @campaigns = DashboardPolicy::Scope.new(current_user, listing_scope).resolve
  end
  
  def listing_scope
    Campaign.without_event
  end
  
end