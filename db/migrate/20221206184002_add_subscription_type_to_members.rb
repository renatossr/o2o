class AddSubscriptionTypeToMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :members, :subscription_type, :integer, default: 1
  end
end
