class CreateGRefreshTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :g_refresh_tokens do |t|
      t.string :refresh_token

      t.timestamps
    end
  end
end
