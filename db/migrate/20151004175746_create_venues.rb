class CreateVenues < ActiveRecord::Migration
  def change
    create_table :venues do |t|
      t.string :name, null: false
      t.string :address, null: false
      t.text :description, null: false
      t.integer :capacity, null: false

      t.timestamps null: false
    end
  end
end
