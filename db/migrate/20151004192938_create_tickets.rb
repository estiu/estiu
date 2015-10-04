class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.references :attendee, index: true, foreign_key: true, null: false
      t.references :event, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
