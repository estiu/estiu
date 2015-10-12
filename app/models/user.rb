class User < ActiveRecord::Base
  
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :confirmable # Excluded: :registerable
  
  def remember_me
    true
  end
  
end
