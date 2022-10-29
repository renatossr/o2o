class AddQuantityToBillingItem < ActiveRecord::Migration[7.0]
  def change
    add_column :billing_items, :quantity, :integer
  end
end
