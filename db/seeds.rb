if Rails.env.development?
  FG.create :campaign
  FG.create :user, roles: Roles.all, email: 'vemv@vemv.net', password: 'p'
end