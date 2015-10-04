class CreateArtists < ActiveRecord::Migration
  def change
    create_table :artists do |t|
      t.string :name
      t.string :telephone
      t.string :email
      t.string :website

      t.timestamps null: false
    end
  end
end
