class AddRoleToUsers < ActiveRecord::Migration
  def change
    add_column :users, :roles, :string, array: true, default: [], null: false
  end
end
