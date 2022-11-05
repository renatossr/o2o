class AddBillingItemIdToWorkout < ActiveRecord::Migration[7.0]
  def change
    add_column :workouts, :billing_item_id, :integer
  end
end
