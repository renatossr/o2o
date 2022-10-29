class ChangeGRefreshTokenToGToken < ActiveRecord::Migration[7.0]
  def change
    rename_table :g_refresh_tokens, :g_tokens
    rename_column :g_tokens, :refresh_token, :token
    add_column :g_tokens, :token_type, :string
  end
end
