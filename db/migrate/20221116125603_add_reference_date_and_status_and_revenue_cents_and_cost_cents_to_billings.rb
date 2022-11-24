class AddReferenceDateAndStatusAndRevenueCentsAndCostCentsToBillings < ActiveRecord::Migration[7.0]
  def change
    add_column :billings, :reference_date, :date
    add_column :billings, :status, :integer, default: 0
    add_column :billings, :revenue_cents, :integer
    add_column :billings, :cost_cents, :integer
  end
end
