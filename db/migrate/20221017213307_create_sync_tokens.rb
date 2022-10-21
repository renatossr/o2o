class CreateSyncTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :sync_tokens do |t|
      t.string :token

      t.timestamps
    end
  end
end
