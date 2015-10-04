class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name
      t.datetime :starts_at
      t.integer :duration

      t.timestamps null: false
    end
  end
end
