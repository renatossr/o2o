class ChangeExternalUrlTypeToText < ActiveRecord::Migration[7.0]
  def change
    change_column :calendar_events, :external_url, :text
  end
end
