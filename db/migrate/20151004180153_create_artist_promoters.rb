class CreateArtistPromoters < ActiveRecord::Migration
  def change
    create_table :artist_promoters do |t|
      t.string :name
      t.string :email
      t.string :website

      t.timestamps null: false
    end
  end
end
