class AddDueDateToInvoices < ActiveRecord::Migration[7.0]
  def change
    add_column :invoices, :due_date, :date
  end
end
