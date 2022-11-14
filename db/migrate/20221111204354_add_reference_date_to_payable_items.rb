class AddReferenceDateToPayableItems < ActiveRecord::Migration[7.0]
  def change
    add_column :payable_items, :reference_date, :date
  end
end
