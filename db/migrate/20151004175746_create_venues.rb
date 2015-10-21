class CreateVenues < ActiveRecord::Migration
  def change
    create_table :venues do |t|
      t.string :name
      t.string :address
      t.text :description
      t.integer :capacity

      t.timestamps null: false
    end
  end
end
