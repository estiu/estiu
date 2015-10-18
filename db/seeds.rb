if Rails.env.development?
  FG.create :campaign
  FG.create :user, :attendee_role, email: 'vemv@vemv.net', password: 'p'
  FG.create :user, :event_promoter_role, email: 'vemv91@gmail.com', password: 'p'
end