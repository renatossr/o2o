class CreateCalendarEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :calendar_events do |t|
      t.string :external_id
      t.string :title
      t.string :status
      t.string :external_url
      t.text :description
      t.string :location
      t.timestamp :start_at
      t.timestamp :end_at

      t.timestamps
    end
    add_index :calendar_events, :external_id
  end
end
