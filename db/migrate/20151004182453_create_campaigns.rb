class CreateCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
      t.string :unfulfillment_check_id
      t.datetime :event_rejected_at
      t.datetime :fulfilled_at
      t.datetime :unfulfilled_at
      t.references :campaign_draft, index: false, foreign_key: true, null: false
      t.timestamps null: false
    end
    add_index :campaigns, :campaign_draft_id, unique: true
  end
end
