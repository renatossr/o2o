class AddStatusToMembersWorkouts < ActiveRecord::Migration[7.0]
  def change
    add_column :members_workouts, :status, :int, default: nil
  end
end
