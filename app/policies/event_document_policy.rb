class EventDocumentPolicy < ApplicationPolicy
  
  def destroy?
    user.event_promoter? &&
    record.event.campaign.event_promoter == user.event_promoter &&
    !record.event.submitted_at
  end

end