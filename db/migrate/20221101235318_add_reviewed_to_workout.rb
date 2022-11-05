class AddReviewedToWorkout < ActiveRecord::Migration[7.0]
  def change
    add_column :workouts, :reviewed, :boolean, default: false
  end
end
