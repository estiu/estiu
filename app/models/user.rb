class User < ActiveRecord::Base
  
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :confirmable, :registerable
  
  belongs_to :event_promoter
  
  validates :role, inclusion: Roles.all.map(&:to_s)
  validate :role_object_presence, unless: :admin?
  validate :no_unrelated_objects, unless: :admin?
  
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
  
  Roles.with_associated_models.each do |role|
    belongs_to role
    validates_associated role, if: ->(record){ record.send("#{role}?") }
    accepts_nested_attributes_for role
  end
  
  def role_object_presence
    return if role.blank?
    unless self.send(role)
      errors[role] << "Object associated by #{role}_id must be present"
    end
  end
  
  def no_unrelated_objects
    Roles.with_associated_models.each do |role|
      unless self.send("#{role}?")
        if self.send(role)
          errors[role] << "Unrelated object #{role} associated with user with different role (#{self.role})"
        end
      end
    end
  end
  
end
