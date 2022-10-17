class AddPaidAtToInvoices < ActiveRecord::Migration[7.0]
  def change
    add_column :invoices, :paid_at, :date
  end
end
