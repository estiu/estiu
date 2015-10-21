class AddVenueToCampaign < ActiveRecord::Migration
  def change
    add_reference :campaigns, :venue, index: true, foreign_key: true, null: false
  end
end
