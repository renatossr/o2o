class AddTotalCentsToItems < ActiveRecord::Migration[7.0]
  def change
    add_column :items, :total_cents, :integer
  end
end
