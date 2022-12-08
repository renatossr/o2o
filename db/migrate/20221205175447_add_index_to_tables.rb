class AddIndexToTables < ActiveRecord::Migration[7.0]
  def change
    add_index :members_workouts, :member_id
    add_index :members_workouts, :workout_id
    add_index :workouts, :calendar_event_id
  end
end
