class AddDefaultValueToPayablesStatus < ActiveRecord::Migration[7.0]
  def change
    change_column :payables, :status, :string, default: "draft"
  end
end
