class AddStatusToPayables < ActiveRecord::Migration[7.0]
  def change
    add_column :payables, :status, :integer, default: 0
  end
end
