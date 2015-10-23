class User < ActiveRecord::Base
  
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :confirmable, :registerable
  
  belongs_to :event_promoter
  
  validate :roles_inclusion
  validate :role_object_presence
  validate :no_unrelated_objects
  
  def self.allow_unconfirmed_access_for
    90.minutes
  end
  
  def to_s
    email
  end
  
  def remember_me
    true
  end
  
  Roles.all.each do |role|
    define_method "#{role}?" do
      self.roles.include?(role)
    end
  end
  
  Roles.with_associated_models.each do |role|
    belongs_to role.to_sym, inverse_of: :user
    validates_associated role.to_sym, if: ->(record){ record.send("#{role}?") }
    accepts_nested_attributes_for role.to_sym
    define_singleton_method "#{role}s" do
      where("'#{role}' = ANY (roles)")
    end
  end
  
  def roles_inclusion
    roles.any? && roles.all?{|role| Roles.all.include? role }
  end
  
  def role_object_presence
    roles.each do |role|
      if Roles.with_associated_models.map.include? role
        unless self.send(role)
          errors[role] << "Object associated by #{role}_id must be present"
        end
      end
    end
  end
  
  def no_unrelated_objects
    Roles.with_associated_models.each do |role|
      if self.send(role) && !self.send("#{role}?")
        errors[role] << "Unrelated object #{role} associated with user with different role (#{self.send(role)})"
      end
    end
  end
  
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end
  
end
