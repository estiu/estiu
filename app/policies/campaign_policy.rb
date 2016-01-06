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
    
    active_time = record.active_time?
    attendee_did_pledge = user.attendee ? user.attendee.pledged?(record) : false
    is_the_event_promoter = user.event_promoter ? record.event_promoter == user.event_promoter : false
    
    generic = active_time || attendee_did_pledge || is_the_event_promoter
    
    if record.visibility == Campaign::PUBLIC_VISIBILITY
      generic
    elsif record.invite_token && (record.invite_token == record.passed_invite_token)
      generic
    elsif (record.visibility == Campaign::APP_VISIBILITY) && logged_in?
      generic
    elsif is_the_event_promoter
      true
    elsif attendee_did_pledge
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