class ChangeStatusToIntegerForMembersWorkouts < ActiveRecord::Migration[7.0]
  def change
    #change_column :members_workouts, :status, "integer USING status::integer", default: 0
  end
end
