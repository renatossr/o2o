class AddStartAtIndexToWorkouts < ActiveRecord::Migration[7.0]
  def change
    add_index :workouts, :start_at
  end
end
