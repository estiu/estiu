if Rails.env.development?
  FG.create :campaign
  FG.create :user, roles: Roles.all, email: 'vemv@vemv.net', password: 'p'
  FG.create :venue, name: 'Moog'
  FG.create :venue, name: 'Razzmatazz'
  FG.create :venue, name: 'Ker'
  FG.create :venue, name: 'City Hall'
end