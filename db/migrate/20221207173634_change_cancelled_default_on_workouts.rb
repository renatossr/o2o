class ChangeCancelledDefaultOnWorkouts < ActiveRecord::Migration[7.0]
  def change
    change_column :workouts, :cancelled, :boolean, default: false
  end
end
