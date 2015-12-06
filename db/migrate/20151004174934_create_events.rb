class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name, null: false
      t.datetime :starts_at, null: false
      t.integer :duration, null: false

      t.timestamps null: false
    end
  end
end
