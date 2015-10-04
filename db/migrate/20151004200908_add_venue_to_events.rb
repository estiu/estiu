class AddVenueToEvents < ActiveRecord::Migration
  def change
    add_reference :events, :venue, index: true, foreign_key: true
  end
end
