class CreateResidentAdvisorPaths < ActiveRecord::Migration
  def change
    create_table :resident_advisor_paths do |t|
      t.string :value

      t.timestamps null: false
    end
  end
end
