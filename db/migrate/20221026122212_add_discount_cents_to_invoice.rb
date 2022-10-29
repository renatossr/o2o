class AddDiscountCentsToInvoice < ActiveRecord::Migration[7.0]
  def change
    add_column :invoices, :discount_cents, :integer, default: 0
  end
end
