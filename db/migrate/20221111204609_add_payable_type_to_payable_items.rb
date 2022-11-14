class AddPayableTypeToPayableItems < ActiveRecord::Migration[7.0]
  def change
    add_column :payable_items, :payable_type, :string
  end
end
