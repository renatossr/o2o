class AddPayableTypeToPayables < ActiveRecord::Migration[7.0]
  def change
    add_column :payables, :payable_type, :string
  end
end
