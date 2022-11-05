class Invoice < ApplicationRecord
  belongs_to :member
  has_many :billing_items

  accepts_nested_attributes_for :billing_items, allow_destroy: true

  scope :all_processing, -> { where(status: "processing") }
  scope :all_cancelling, -> { where(status: "cancelling") }
  scope :all_from_cycles, -> { where(invoice_type: "billing_cycle") }
  scope :all_manual, -> { where(invoice_type: "manual") }

  after_save :set_billing_items_status

  def update_totals!
    self.total_value_cents = 0
    self.billing_items.each { |item| self.total_value_cents += item.value_cents }
    self.save!
  end

  def final_value_cent
    total_value_cents.to_i - discount_cents.to_i
  end

  def status_color
    case self.status
    when "draft"
      "primary"
    when "pending"
      "warning"
    when "canceled"
      "secondary"
    when "expired"
      "warning"
    when "paid"
      "success"
    else
      "secondary"
    end
  end

  def self.list_billing_cycles
    Invoice.all_from_cycles.pluck(:reference_date).uniq
  end

  def new_from_workout(workout)
    new_billing_item = BillingItem.new(description: "Aula Avulsa", quantity: 1)
  end

  def issue_invoice
    self.status = "processing"
    self.save!
  end

  def cancel_invoice
    self.status = "cancelling" unless self.status = "canceled"
    self.save!
  end

  def set_billing_items_status
    status = self.status
    self.billing_items.each do |item|
      item.status = status
      item.save!
    end
  end
end
