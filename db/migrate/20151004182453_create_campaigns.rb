class CreateCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
      t.string :name, null: false
      t.string :unfulfillment_check_id
      t.text :description
      t.integer :goal_cents
      t.integer :minimum_pledge_cents
      t.datetime :starts_at
      t.datetime :ends_at
      t.datetime :approved_at, :datetime
      t.datetime :rejected_at, :datetime
      t.datetime :submitted_at, :datetime
      t.datetime :event_rejected_at
      t.datetime :fulfilled_at
      t.datetime :unfulfilled_at
      t.boolean :skip_past_date_validations
      t.string :visibility
      t.boolean :generate_invite_link
      t.boolean :starts_immediately
      t.string :invite_token
      t.string :time_zone
      t.timestamps null: false
    end
  end
end
