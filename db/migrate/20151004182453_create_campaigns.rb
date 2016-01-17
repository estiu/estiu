class CreateCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
      t.string :name, null: false
      t.string :unfulfillment_check_id
      t.text :description
      t.integer :goal_cents
      t.integer :minimum_pledge_cents
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.datetime :event_rejected_at
      t.datetime :fulfilled_at
      t.datetime :unfulfilled_at
      t.boolean :skip_past_date_validations
      t.string :visibility, null: false
      t.boolean :generate_invite_link, null: false
      t.string :invite_token
      t.timestamps null: false
    end
  end
end
