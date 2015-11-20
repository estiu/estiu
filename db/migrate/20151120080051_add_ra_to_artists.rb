class AddRaToArtists < ActiveRecord::Migration
  def change
    add_reference :artists, :resident_advisor_path, index: true, foreign_key: true
  end
end
