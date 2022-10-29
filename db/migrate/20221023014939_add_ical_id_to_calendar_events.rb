class AddIcalIdToCalendarEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :calendar_events, :ical_id, :string
  end
end
