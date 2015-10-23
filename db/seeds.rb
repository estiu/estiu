if Rails.env.development?
  FG.create :user, roles: Roles.all, email: 'vemv@vemv.net', password: 'p'
  FG.create :venue, name: 'Moog'
  FG.create :venue, name: 'Razzmatazz'
  FG.create :venue, name: 'Ker'
  FG.create :venue, name: 'City Hall'
  FG.create :campaign
  FG.create :campaign, :almost_fulfilled
end