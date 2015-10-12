class User < ActiveRecord::Base
  
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :confirmable, :registerable
  
  def to_s
    email
  end
  
  def remember_me
    true
  end
  
end
