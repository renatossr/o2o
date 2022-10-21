class AddProcessedToCalendarEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :calendar_events, :processed, :boolean, default: false
  end
end
