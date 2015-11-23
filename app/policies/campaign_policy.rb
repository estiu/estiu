class CampaignPolicy < ApplicationPolicy
  
  def index?
    logged_in?
  end
  
  def mine?
    logged_in?
  end
  
  def new_or_create?
    user.event_promoter?
  end
  
  def show?
    true
  end
  
end