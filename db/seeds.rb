if Rails.env.development?
  user = FG.create :user, roles: Roles.all, email: 'vemv91@gmail.com', password: 'p'
  4.times { FG.create :venue }
  FG.create :campaign
  FG.create :campaign, :almost_fulfilled
  2.times { FG.create :campaign, :unfulfilled, including_attendees: [user.attendee] }
  2.times { FG.create :campaign, :fulfilled, event_promoter_id: user.event_promoter_id }
  FG.create :campaign, :with_referred_attendee, referred_attendee: user.attendee
  FG.create :event, event_promoter_id: user.event_promoter_id
  !user.attendee.credits.count.zero? || fail
  c = FG.create :campaign, :fulfilled, :with_submitted_event, including_attendees: [user.attendee]
  c.event.reload.approve!
end