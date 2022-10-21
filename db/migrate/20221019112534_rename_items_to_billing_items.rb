class RenameItemsToBillingItems < ActiveRecord::Migration[7.0]
  def change
    rename_table :items, :billing_items
  end
end
