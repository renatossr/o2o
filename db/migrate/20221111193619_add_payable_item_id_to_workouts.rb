class AddPayableItemIdToWorkouts < ActiveRecord::Migration[7.0]
  def change
    add_column :workouts, :payable_item_id, :integer
  end
end
