class CreatePledges < ActiveRecord::Migration
  def change
    create_table :pledges do |t|
      t.references :attendee, index: true, foreign_key: true
      t.references :campaign, index: true, foreign_key: true
      t.integer :amount_cents

      t.timestamps null: false
    end
  end
end
