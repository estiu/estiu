class CreateCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
      t.string :name
      t.string :unfulfillment_check_id
      t.text :description
      t.integer :goal_cents
      t.integer :minimum_pledge_cents
      t.datetime :starts_at
      t.datetime :ends_at
      t.datetime :fulfilled_at
      t.boolean :skip_past_date_validations
      t.timestamps null: false
    end
  end
end
