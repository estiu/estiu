class CampaignPolicy < ApplicationPolicy
  
  def index?
    logged_in?
  end
  
  def mine?
    logged_in?
  end
  
  def new?
    user.event_promoter?
  end
  
  def show?
    true
  end
  
end