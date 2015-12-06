class CreateEventPromoters < ActiveRecord::Migration
  def change
    create_table :event_promoters do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :website, null: false

      t.timestamps null: false
    end
  end
end
