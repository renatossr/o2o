class ChangeStatusToIntegerForBillingItems < ActiveRecord::Migration[7.0]
  def change
    change_column :billing_items, :status, :int, default: 0
  end
end
