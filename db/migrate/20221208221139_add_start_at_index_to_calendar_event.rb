class AddStartAtIndexToCalendarEvent < ActiveRecord::Migration[7.0]
  def change
    add_index :calendar_events, :start_at
  end
end
