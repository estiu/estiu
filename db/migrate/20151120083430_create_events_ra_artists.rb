class CreateEventsRaArtists < ActiveRecord::Migration
  def change
    create_table :events_ra_artists do |t|
      t.references :event, index: true, foreign_key: true
      t.references :ra_artist, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
