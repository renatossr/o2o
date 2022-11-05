class AddBillingItemIdToMembersWorkouts < ActiveRecord::Migration[7.0]
  def change
    add_column :members_workouts, :billing_item_id, :integer, optional: true
  end
end
