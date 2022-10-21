class CreateGCalendars < ActiveRecord::Migration[7.0]
  def change
    create_table :g_calendars do |t|

      t.timestamps
    end
  end
end
