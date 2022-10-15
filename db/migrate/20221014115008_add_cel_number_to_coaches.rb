class AddCelNumberToCoaches < ActiveRecord::Migration[7.0]
  def change
    add_column :coaches, :cel_number, :string
  end
end
