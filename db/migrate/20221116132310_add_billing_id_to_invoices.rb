class AddBillingIdToInvoices < ActiveRecord::Migration[7.0]
  def change
    add_column :invoices, :billing_id, :integer
  end
end
