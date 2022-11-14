class Payable < ApplicationRecord
  belongs_to :coach
  has_many :payable_items, dependent: :destroy

  before_save :update_totals

  def update_totals!
    self.total_value_cents = 0
    self.payable_items.each { |item| self.total_value_cents += item.value_cents }
    self.save!
  end

  def update_totals
    self.total_value_cents = 0
    self.payable_items.each { |item| self.total_value_cents += item.value_cents }
  end
end
