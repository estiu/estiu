class CampaignPolicy < ApplicationPolicy
  
  def index?
    true
  end
  
  def mine?
    user.id.present?
  end
  
  def new?
    user.event_promoter?
  end
  
  def show?
    true
  end
  
end