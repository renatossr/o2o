class RemoveIdFromMembersWorkouts < ActiveRecord::Migration[7.0]
  def change
    remove_column :members_workouts, :id
  end
end
