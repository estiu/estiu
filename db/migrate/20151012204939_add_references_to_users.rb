class AddReferencesToUsers < ActiveRecord::Migration
  def change
    %i(artist artist_promoter event_promoter attendee).each do |column|
      add_column :users, "#{column}_id", :integer, null: true
      add_foreign_key :users, "#{column}s".to_sym
    end
  end
end
