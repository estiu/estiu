class CreateCredits < ActiveRecord::Migration
  def change
    create_table :credits do |t|
      t.references :attendee, index: true, foreign_key: true
      t.references :pledge, index: true, foreign_key: true
      t.integer :amount_cents, null: false
      t.boolean :charged, null: false

      t.timestamps null: false
    end
  end
end
