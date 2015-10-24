class AddOmniauthToUsers < ActiveRecord::Migration
  def change
    add_column :users, :facebook_user_id, :string
    add_column :users, :signed_up_via_facebook, :boolean
    add_column :users, :facebook_access_token, :string
    add_column :users, :facebook_access_token_expires, :datetime
  end
end
