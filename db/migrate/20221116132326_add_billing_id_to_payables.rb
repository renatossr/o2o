class AddBillingIdToPayables < ActiveRecord::Migration[7.0]
  def change
    add_column :payables, :billing_id, :integer
  end
end
