class AddEventPromoterToCampaigns < ActiveRecord::Migration
  def change
    add_reference :campaigns, :event_promoter, index: true, foreign_key: true
  end
end
