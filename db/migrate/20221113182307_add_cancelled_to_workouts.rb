class AddCancelledToWorkouts < ActiveRecord::Migration[7.0]
  def change
    add_column :workouts, :cancelled, :boolean
  end
end
