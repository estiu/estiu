class AddReferencesToUsers < ActiveRecord::Migration
  def change
    Roles.with_associated_models.each do |column|
      add_column :users, "#{column}_id", :integer, null: true
      add_foreign_key :users, "#{column}s".to_sym
    end
  end
end
