class CreateAttendees < ActiveRecord::Migration
  def change
    create_table :attendees do |t|
      t.string :first_name
      t.string :last_name
      t.string :entity_type_shown_at_signup
      t.integer :entity_id_shown_at_signup

      t.timestamps null: false
    end
  end
end
