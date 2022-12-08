class ChangeStatusDefaultToNullForMembersWorkouts < ActiveRecord::Migration[7.0]
  def change
    #change_column :members_workouts, :status, "integer USING status::integer", default: nil
  end
end
