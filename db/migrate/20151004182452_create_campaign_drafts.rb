class CreateCampaignDrafts < ActiveRecord::Migration
  def change
    create_table :campaign_drafts do |t|
      t.string :name, null: false
      t.text :description
      t.integer :goal_cents
      t.integer :minimum_pledge_cents
      t.datetime :starts_at
      t.datetime :ends_at
      t.datetime :approved_at, :datetime
      t.datetime :rejected_at, :datetime
      t.datetime :submitted_at, :datetime
      t.boolean :skip_past_date_validations
      t.string :visibility
      t.boolean :generate_invite_link
      t.boolean :starts_immediately
      t.string :invite_token
      t.string :time_zone
      t.references :venue, index: true, foreign_key: true, null: false
      t.references :event_promoter, index: true, foreign_key: true, null: false
      t.timestamps null: false
    end
  end
end
