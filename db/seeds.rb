if Rails.env.development?
  FG.create :campaign
  FG.create :user, roles: Roles.all, email: 'vemv@vemv.net', password: 'p'
  FG.create :venue, name: 'Moog', capacity: (Random.rand * 2000).to_i + 100
  FG.create :venue, name: 'Razzmatazz', capacity: (Random.rand * 2000).to_i + 100
  FG.create :venue, name: 'Ker', capacity: (Random.rand * 2000).to_i + 100
  FG.create :venue, name: 'City Hall', capacity: (Random.rand * 2000).to_i + 100
end