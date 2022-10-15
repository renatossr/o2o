class AddActiveToMember < ActiveRecord::Migration[7.0]
  def change
    add_column :members, :active, :boolean, default: true
  end

  def active?
    active
  end
end
