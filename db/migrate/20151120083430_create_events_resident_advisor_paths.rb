class CreateEventsResidentAdvisorPaths < ActiveRecord::Migration
  def change
    create_table :events_resident_advisor_paths do |t|
      t.references :event, index: true, foreign_key: true
      t.references :resident_advisor_path, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
