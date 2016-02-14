class CampaignDraftPolicy < ApplicationPolicy
  
  def new_or_create?
    user.event_promoter?
  end
  
  def show?
    (user.event_promoter == record.event_promoter) || user.admin?
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
  
  %i(approve? reject?).each do |method|
    define_method method do
      user.admin? && record.must_be_reviewed?
    end
  end
  
end