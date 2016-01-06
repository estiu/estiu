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
    
    if record.visibility == Campaign::PUBLIC_VISIBILITY
      active_time || attendee_did_pledge
    elsif record.invite_token && (record.invite_token == record.passed_invite_token)
      active_time || attendee_did_pledge
    elsif record.visibility == Campaign::APP_VISIBILITY
      (active_time && logged_in?) || attendee_did_pledge
    elsif user.event_promoter? && (record.event_promoter == user.event_promoter)
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