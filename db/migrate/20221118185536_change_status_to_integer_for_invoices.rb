class ChangeStatusToIntegerForInvoices < ActiveRecord::Migration[7.0]
  def change
    change_column :invoices, :status, :int, default: 0
  end
end
