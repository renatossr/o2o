class AddGympassFlagToWorkout < ActiveRecord::Migration[7.0]
  def change
    add_column :workouts, :gympass, :boolean, default: 0
  end
end
