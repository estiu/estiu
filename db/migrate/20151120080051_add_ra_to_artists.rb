class AddRaToArtists < ActiveRecord::Migration
  def change
    add_reference :artists, :ra_artist, index: true, foreign_key: true
  end
end
