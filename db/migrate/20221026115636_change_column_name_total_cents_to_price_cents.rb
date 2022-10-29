class ChangeColumnNameTotalCentsToPriceCents < ActiveRecord::Migration[7.0]
  def change
    rename_column :billing_items, :total_cents, :price_cents
  end
end
