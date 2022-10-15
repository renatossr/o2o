class Item < ApplicationRecord
  belongs_to :invoices
  belongs_to :member
end
