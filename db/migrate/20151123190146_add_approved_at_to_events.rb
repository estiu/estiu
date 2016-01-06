class AddApprovedAtToEvents < ActiveRecord::Migration
  def change
    add_column :events, :approved_at, :datetime
    add_column :events, :rejected_at, :datetime
    add_column :events, :submitted_at, :datetime
  end
end
