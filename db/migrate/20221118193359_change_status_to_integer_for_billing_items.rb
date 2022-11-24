class ChangeStatusToIntegerForBillingItems < ActiveRecord::Migration[7.0]
  def change
    change_column :billing_items, :status, :integer, default: 0
  end
end
