class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name, null: false
      t.datetime :starts_at, null: false
      t.integer :duration_hours, null: false
      t.integer :duration_minutes, null: false, default: 0
      t.boolean :skip_past_date_validations
      t.timestamps null: false
    end
  end
end
