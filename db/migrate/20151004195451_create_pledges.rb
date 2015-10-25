class CreatePledges < ActiveRecord::Migration
  def change
    create_table :pledges do |t|
      t.references :attendee, index: true, foreign_key: true, null: false
      t.references :campaign, index: true, foreign_key: true, null: false
      t.integer :amount_cents
      t.integer :discount_cents, default: 0
      t.integer :originally_pledged_cents
      t.string :stripe_charge_id
      t.string :referral_email

      t.timestamps null: false
    end
  end
end
