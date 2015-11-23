class CreateEventDocuments < ActiveRecord::Migration
  def change
    create_table :event_documents do |t|
      t.references :event_promoter, index: true, foreign_key: true
      t.string :filename

      t.timestamps null: false
    end
  end
end
