class AddStatusToWorkout < ActiveRecord::Migration[7.0]
  def change
    add_column :workouts, :status, :string, default: "confirmed"
  end
end
