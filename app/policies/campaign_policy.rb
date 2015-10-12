class CampaignPolicy < ApplicationPolicy
  
  def index?
    true
  end
  
  def create?
    @user.event_promoter?
  end
  
  def show?
    true
  end
  
end