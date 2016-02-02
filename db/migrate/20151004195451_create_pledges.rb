class CreatePledges < ActiveRecord::Migration
  def change
    create_table :pledges do |t|
      t.references :attendee, index: true, foreign_key: true, null: false
      t.references :campaign, index: true, foreign_key: true, null: false
      t.integer :amount_cents, null: false
      t.integer :discount_cents, default: 0, null: false
      t.integer :originally_pledged_cents, null: false
      t.string :stripe_charge_id
      t.string :stripe_refund_id
      t.string :referral_email
      t.integer :desired_credit_ids, array: true, null: false, default: []

      t.timestamps null: false
    end
    add_index :pledges, [:campaign_id, :attendee_id], unique: true
  end
end
