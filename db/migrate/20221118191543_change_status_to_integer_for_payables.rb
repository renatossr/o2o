class ChangeStatusToIntegerForPayables < ActiveRecord::Migration[7.0]
  def change
    change_column :payables, :status, :integer, default: 0
  end
end
