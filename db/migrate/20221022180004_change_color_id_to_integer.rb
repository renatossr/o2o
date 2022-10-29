class ChangeColorIdToInteger < ActiveRecord::Migration[7.0]
  def change
    change_column :calendar_events, :color_id, :integer
  end
end
