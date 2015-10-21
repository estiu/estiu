class AddContactableToContacts < ActiveRecord::Migration
  def change
    add_reference :contacts, :contactable, polymorphic: true, index: true, null: false
  end
end
