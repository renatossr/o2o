class RemoveToAndCoach < ActiveRecord::Migration[7.0]
  def change
    remove_column :coaches, :to
    remove_column :coaches, :coach
  end
end
