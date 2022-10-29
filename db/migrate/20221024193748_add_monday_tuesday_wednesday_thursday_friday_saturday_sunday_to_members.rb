class AddMondayTuesdayWednesdayThursdayFridaySaturdaySundayToMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :members, :monday, :integer
    add_column :members, :tuesday, :integer
    add_column :members, :wednesday, :integer
    add_column :members, :thursday, :integer
    add_column :members, :friday, :integer
    add_column :members, :saturday, :integer
    add_column :members, :sunday, :integer
  end
end
