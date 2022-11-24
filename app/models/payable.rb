class Payable < ApplicationRecord
  STATUS_COLORS = { draft: "primary", pending: "warning", expired: "warning", paid: "success" }
  enum status: { draft: 0, processing: 10, pending: 11, paid: 12, cancelling: 20, cancelled: 21, expired: 30 }

  belongs_to :coach
  belongs_to :billing, optional: true
  has_many :payable_items, dependent: :destroy

  accepts_nested_attributes_for :payable_items, allow_destroy: true

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

  def final_value_cents
    total_value_cents.to_i - discount_cents.to_i
  end

  def status_color
    STATUS_COLORS[status&.to_sym] || "secondary"
  end

  def issue_payable
    self.processing!
  end

  ransacker :total_value_cents do
    Arel.sql("CONVERT(#{table_name}.total_value_cents, CHAR(8))")
  end
end
