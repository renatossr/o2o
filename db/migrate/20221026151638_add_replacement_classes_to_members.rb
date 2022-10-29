class AddReplacementClassesToMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :members, :replacement_classes, :integer, default: 0
  end
end
