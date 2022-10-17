class AddSubscriptionPriceAndClassPriceToMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :members, :subscription_price, :integer
    add_column :members, :class_price, :integer
  end
end
