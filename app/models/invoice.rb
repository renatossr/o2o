class Invoice < ApplicationRecord
  belongs_to :member
  has_many :items
end
