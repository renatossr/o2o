class Invoice < ApplicationRecord
  belongs_to :member
  has_many :billing_items, dependent: :destroy

  validates :member_id, presence: true
  validates :billing_items, presence: true

  accepts_nested_attributes_for :billing_items, allow_destroy: true

  scope :all_processing, -> { where(status: "processing") }
  scope :all_cancelling, -> { where(status: "cancelling") }
  scope :all_from_cycles, -> { where(invoice_type: "billing_cycle") }
  scope :all_manual, -> { where(invoice_type: "manual") }
  scope :all_ad_hoc, -> { where(invoice_type: "ad-hoc") }
  scope :all_paid, -> { where(invoice_type: "paid") }

  before_save :update_totals
  after_save :set_billing_items_status

  def update_totals!
    self.total_value_cents = 0
    self.billing_items.each { |item| self.total_value_cents += item.value_cents }
    self.save!
  end

  def update_totals
    self.total_value_cents = 0
    self.billing_items.each { |item| self.total_value_cents += item.value_cents }
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

  def self.create_from_workout(workout)
    billing_items = []
    workout.members_workouts.each do |member_workout|
      member = member_workout.member
      unless member.loyal || member_workout.billed?
        member_responsible = member.responsible
        invoice =
          Invoice.where(
            reference_date: Date.current.beginning_of_month,
            member: member_responsible,
            invoice_type: "ad-hoc",
            status: "draft",
          )
        invoice =
          Invoice.new(
            status: "draft",
            reference_date: Date.current.beginning_of_month,
            member: member_responsible,
            invoice_type: "ad-hoc",
          ) if invoice.blank?

        new_item =
          BillingItem.new(
            member_id: member.id,
            payer: member_responsible,
            description: "Aula Avulsa",
            quantity: 1,
            price_cents: member.class_price,
            billing_type: "ad-hoc",
            status: "draft",
            reference_date: Date.current.beginning_of_month,
          )
        new_item.members_workouts << member_workout
        invoice.billing_items << new_item
        invoice.save!
      end
    end
  end

  def whatsapp_link
    final_link = self.member.whatsapp_link
    message = "Segue o link da fatura: #{self.external_url}"
    final_link = final_link + "?text=" + URI.encode_www_form_component(message)
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
