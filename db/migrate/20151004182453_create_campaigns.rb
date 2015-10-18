class CreateCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
      t.string :name
      t.text :description
      t.integer :goal_cents
      t.integer :recommended_pledge_cents
      t.integer :minimum_pledge_cents
      t.datetime :starts_at
      t.datetime :ends_at

      t.timestamps null: false
    end
  end
end
