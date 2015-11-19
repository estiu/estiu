if Rails.env.development?
  user = FG.create :user, roles: Roles.all, email: 'vemv91@gmail.com', password: 'p'
  4.times { FG.create :venue }
  FG.create :campaign
  FG.create :campaign, :almost_fulfilled
  FG.create :campaign, :with_referred_attendee, referred_attendee: user.attendee
  FG.create :event, event_promoter_id: user.event_promoter_id
  !user.attendee.credits.count.zero? || fail
end