class AddResponsibleIdToMember < ActiveRecord::Migration[7.0]
  def change
    add_column :members, :responsible_id, :integer
  end
end
