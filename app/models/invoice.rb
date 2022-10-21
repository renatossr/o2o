class Invoice < ApplicationRecord
  belongs_to :member
  has_many :billing_items

  def update_totals!
    self.total_value_cents = billing_items.sum(:total_cents)
    save!
  end
end
