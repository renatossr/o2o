class AddEventIdToWorkout < ActiveRecord::Migration[7.0]
  def change
    add_column :workouts, :calendar_event_id, :integer
  end
end
