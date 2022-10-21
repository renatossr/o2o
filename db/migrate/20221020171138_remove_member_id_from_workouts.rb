class RemoveMemberIdFromWorkouts < ActiveRecord::Migration[7.0]
  def change
    remove_column :workouts, :member_id
  end
end
