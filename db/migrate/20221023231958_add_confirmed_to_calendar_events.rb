class AddConfirmedToCalendarEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :calendar_events, :confirmed, :boolean, default: :false
  end
end
