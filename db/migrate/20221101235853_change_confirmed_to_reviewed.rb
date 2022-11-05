class ChangeConfirmedToReviewed < ActiveRecord::Migration[7.0]
  def change
    rename_column :calendar_events, :confirmed, :reviewed
  end
end
