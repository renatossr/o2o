class GToken < ApplicationRecord
  def self.get_access_token
    token = GToken.where(token_type: "access").last
    token.token unless token.blank?
  end

  def self.get_refresh_token
    token = GToken.where(token_type: "refresh").last
    token.token unless token.blank?
  end

  def self.store_access_token(token)
    GToken.create!(token_type: "access", token: token)
  end

  def self.store_refresh_token(token)
    GToken.create!(token_type: "refresh", token: token)
  end
end
