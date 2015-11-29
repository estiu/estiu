class EventDocumentPolicy < ApplicationPolicy
  
  def destroy?
    user.event_promoter? &&
    record.event.campaign.event_promoter == user.event_promoter &&
    !record.event.approved_at
  end

end