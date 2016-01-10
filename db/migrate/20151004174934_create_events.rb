class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name, null: false
      t.datetime :starts_at, null: false
      t.integer :duration, null: false
      t.boolean :skip_past_date_validations
      t.timestamps null: false
    end
  end
end
