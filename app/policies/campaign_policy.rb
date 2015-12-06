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
    if record.visibility == Campaign::PUBLIC_VISIBILITY
      true
    elsif record.invite_token
      if (record.invite_token == record.passed_invite_token)
        true
      elsif user.attendee? && user.attendee.pledged?(record)
        true
      else
        false
      end
    elsif record.visibility == Campaign::APP_VISIBILITY
      logged_in?
    elsif user.event_promoter? && (record.event_promoter == user.event_promoter)
      true
    elsif user.admin?
      true
    else
      false
    end
  end
  
  class Scope < Scope
    def resolve
      scope.select {|campaign|
        CampaignPolicy.new(user, campaign).show?
      }
    end
  end
  
end