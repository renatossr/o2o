class AddPaymentMethodAndPaidCentsToInvoices < ActiveRecord::Migration[7.0]
  def change
    add_column :invoices, :payment_method, :string
    add_column :invoices, :paid_cents, :integer
  end
end
