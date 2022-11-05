class AddIdToMembersWorkouts < ActiveRecord::Migration[7.0]
  def change
    add_column :members_workouts, :id, :primary_key
  end
end
