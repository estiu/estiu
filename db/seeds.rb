if Rails.env.development?
  user = FG.create :user, roles: Roles.all, email: 'vemv91@gmail.com', password: 'p'
  FG.create :venue, name: 'Moog'
  FG.create :venue, name: 'Razzmatazz'
  FG.create :venue, name: 'Ker'
  FG.create :venue, name: 'City Hall'
  FG.create :campaign
  FG.create :campaign, :almost_fulfilled
  FG.create :campaign, :with_referred_attendee, referred_attendee: user.attendee
  FG.create :event, event_promoter_id: user.event_promoter_id
  !user.attendee.credits.count.zero? || fail
end