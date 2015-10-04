class AddCampaignToEvents < ActiveRecord::Migration
  def change
    add_reference :events, :campaign, index: true, foreign_key: true
  end
end
