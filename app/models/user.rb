class User < ActiveRecord::Base
  
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :confirmable, :registerable
  
  def to_s
    email
  end
  
  def remember_me
    true
  end
  
  Roles.all.each do |role|
    define_method "#{role}?" do
      self.role == role.to_s
    end
  end
  
end
