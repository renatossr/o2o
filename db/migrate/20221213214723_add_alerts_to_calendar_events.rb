class AddAlertsToCalendarEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :calendar_events, :alerts, :text, array: true, default: []
  end
end
