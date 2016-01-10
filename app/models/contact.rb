class Contact < ActiveRecord::Base
  
  belongs_to :contactable, polymorphic: true
  
  %i(contactable first_name last_name phone email).each do |attr|
    validates attr, presence: true
  end
  
end
