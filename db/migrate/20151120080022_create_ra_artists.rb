class CreateRaArtists < ActiveRecord::Migration
  def change
    create_table :ra_artists do |t|
      t.string :artist_path, null: false
      t.string :artist_name, null: false
      t.boolean :top1000, default: false, null: false
      
      t.timestamps null: false
    end
    add_index :ra_artists, :artist_path, unique: true
    add_index :ra_artists, :artist_name, unique: true
  end
end
