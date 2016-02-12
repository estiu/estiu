class CampaignDraftPolicy < ApplicationPolicy
  
  def new_or_create?
    user.event_promoter?
  end
  
  def show?
    user.event_promoter == record.event_promoter
  end
  
  def edit_or_update?
    !record.submitted_at && show?
  end
  
  def submit?
    edit_or_update?
  end
  
  def publish?
    show? && record.approved_at? && !record.published_at
  end
  
  def destroy?
    edit_or_update?
  end
  
end