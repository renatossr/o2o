class AddLoyalToMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :members, :loyal, :boolean, default: false
  end
end
