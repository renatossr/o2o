class CreateWorkouts < ActiveRecord::Migration[7.0]
  def change
    create_table :workouts do |t|
      t.integer :member_id
      t.integer :coach_id
      t.timestamp :start_at
      t.timestamp :end_at
      t.string :location
      t.text :comments

      t.timestamps
    end
  end
end
