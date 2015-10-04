class CreateArtistCatalogEntries < ActiveRecord::Migration
  def change
    create_table :artist_catalog_entries do |t|
      t.references :artist, index: true, foreign_key: true
      t.references :artist_promoter, index: true, foreign_key: true
      t.integer :price_cents
      t.integer :act_duration

      t.timestamps null: false
    end
  end
end
