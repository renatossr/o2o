class AddDiscountCentsToPayables < ActiveRecord::Migration[7.0]
  def change
    add_column :payables, :discount_cents, :integer, default: 0
  end
end
