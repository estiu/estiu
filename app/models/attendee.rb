class Attendee < ActiveRecord::Base
  
  has_and_belongs_to_many :events, join_table: :tickets
  has_and_belongs_to_many :campaigns, join_table: :pledges
  has_many :tickets
  has_many :pledges
  has_one :user
  
  %i(first_name last_name user).each do |attr|
    validates attr, presence: true
  end
  
  validates :entity_type_shown_at_signup, inclusion: {in: %w(event campaign), allow_blank: true}
  
  def after_sign_up_path
    if entity_type_shown_at_signup && entity_id_shown_at_signup
      Rails.application.routes.url_helpers.send("#{entity_type_shown_at_signup}_path", entity_id_shown_at_signup)
    else
      Rails.application.routes.url_helpers.root_path
    end
  end
  
  def pledged? campaign
    campaign.pledges.pluck(:attendee_id).include? self.id
  end
  
  def pledged_for campaign
    (campaign.pledges.where(attendee: self).sum(:amount_cents) / 100.0).to_money
  end
  
end
