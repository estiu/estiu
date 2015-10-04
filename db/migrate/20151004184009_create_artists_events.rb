class CreateArtistsEvents < ActiveRecord::Migration
  def change
    create_table :artists_events do |t|
      t.references :artist, index: true, foreign_key: true, null: false
      t.references :event, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
