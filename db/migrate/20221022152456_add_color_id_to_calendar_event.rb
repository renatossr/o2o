class AddColorIdToCalendarEvent < ActiveRecord::Migration[7.0]
  def change
    add_column :calendar_events, :color_id, :string
  end
end
