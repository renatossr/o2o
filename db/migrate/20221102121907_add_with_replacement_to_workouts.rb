class AddWithReplacementToWorkouts < ActiveRecord::Migration[7.0]
  def change
    add_column :workouts, :with_replacement, :boolean, default: false
  end
end
