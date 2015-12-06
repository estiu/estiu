class CreateArtists < ActiveRecord::Migration
  def change
    create_table :artists do |t|
      t.string :name, null: false
      t.string :telephone, null: false
      t.string :email, null: false
      t.string :website, null: false

      t.timestamps null: false
    end
  end
end
