class AddAdditionalClassPricesToMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :members, :double_class_price, :integer
    add_column :members, :triple_class_price, :integer
  end
end
