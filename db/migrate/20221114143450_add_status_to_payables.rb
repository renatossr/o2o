class AddStatusToPayables < ActiveRecord::Migration[7.0]
  def change
    add_column :payables, :status, :string
  end
end
