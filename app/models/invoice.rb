class Invoice < ApplicationRecord
  belongs_to :member
  has_many :billing_items

  accepts_nested_attributes_for :billing_items

  def update_totals!
    self.total_value_cents = 0
    billing_items.each { |item| self.total_value_cents += item.value_cents }
    save!
  end

  def final_value_cent
    total_value_cents - discount_cents
  end
end
