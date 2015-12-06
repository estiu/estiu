class CreateCredits < ActiveRecord::Migration
  def change
    create_table :credits do |t|
      t.references :attendee, index: true, foreign_key: true
      t.references :pledge, index: true, foreign_key: true
      t.integer :amount_cents, null: false
      t.boolean :charged, null: false

      t.timestamps null: false
    end
    add_reference :credits, :refunded_pledge, references: :pledge, index: true
    add_foreign_key :credits, :pledges, column: :refunded_pledge_id
  end
end
