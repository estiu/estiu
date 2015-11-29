class CreateEventDocuments < ActiveRecord::Migration
  def change
    create_table :event_documents do |t|
      t.references :event, index: true, foreign_key: true
      t.string :filename, null: false
      t.string :key, null: false

      t.timestamps null: false
    end
  end
end
