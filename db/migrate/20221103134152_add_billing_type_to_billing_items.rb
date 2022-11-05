class AddBillingTypeToBillingItems < ActiveRecord::Migration[7.0]
  def change
    add_column :billing_items, :billing_type, :string, default: "general"
  end
end
