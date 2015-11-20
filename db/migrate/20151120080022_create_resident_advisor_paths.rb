class CreateResidentAdvisorPaths < ActiveRecord::Migration
  def change
    create_table :resident_advisor_paths do |t|
      t.string :value, null: false
      t.string :artist_name, null: false
      t.boolean :top1000, default: false, null: false
      
      t.timestamps null: false
    end
    add_index :resident_advisor_paths, :value, unique: true
    add_index :resident_advisor_paths, :artist_name, unique: true
  end
end
