class CreateMembersWorkouts < ActiveRecord::Migration[7.0]
  def change
    create_table :members_workouts do |t|
      t.integer :workout_id
      t.integer :member_id

      t.timestamps
    end
  end
end
