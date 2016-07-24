class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name, null: false
      t.date :starts_at_date, null: false
      t.integer :starts_at_hours, null: false
      t.integer :starts_at_minutes, null: false, default: 0
      t.integer :duration_hours, null: false
      t.integer :duration_minutes, null: false, default: 0
      t.boolean :skip_past_date_validations
      t.timestamps null: false
    end
    add_column :events, :approved_at, :datetime
    add_column :events, :rejected_at, :datetime
    add_column :events, :submitted_at, :datetime
  end
end
