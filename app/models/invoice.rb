class Invoice < ApplicationRecord
  STATUS_COLORS = { draft: "primary", pending: "warning", expired: "warning", paid: "success" }
  enum status: { draft: 0, processing: 10, pending: 11, paid: 12, cancelling: 20, cancelled: 21, expired: 30 }

  belongs_to :member
  belongs_to :billing, optional: true
  has_many :billing_items, dependent: :destroy

  validates :member_id, presence: true
  validates :billing_items, presence: true

  accepts_nested_attributes_for :billing_items, allow_destroy: true

  scope :from_cycles, -> { where(invoice_type: "billing_cycle") }
  scope :manual, -> { where(invoice_type: "manual") }
  scope :ad_hoc, -> { where(invoice_type: "ad-hoc") }

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

  def final_value_cents
    total_value_cents.to_i - discount_cents.to_i
  end

  def status_color
    STATUS_COLORS[status&.to_sym] || "secondary"
  end

  def self.create_from_workout(workout)
    billing_items = []
    workout.members_workouts.each do |member_workout|
      member = member_workout.member
      unless member.loyal || member_workout.billed?
        member_responsible = member.responsible
        billing = Billing.find_or_create_by(reference_date: Date.current.beginning_of_month)
        invoice =
          Invoice.find_or_initialize_by(
            reference_date: Date.current.beginning_of_month,
            due_date: Date.current.end_of_month + 5.days,
            member: member_responsible,
            invoice_type: "ad-hoc",
            status: :draft,
          )

        new_item =
          invoice.billing_items.build(
            member_id: member.id,
            payer: member_responsible,
            description: "Aula Avulsa: #{I18n.l(workout.start_at, format: "%a, %d/%m - %H:%M")}",
            quantity: 1,
            price_cents: member.class_price,
            billing_type: "ad-hoc",
            status: :draft,
            reference_date: workout.start_at.to_date,
          )

        new_item.members_workouts << member_workout
        billing.invoices << invoice
        billing.save!
      end
    end
  end

  def cancel_and_mirror
    if self.mirrorable?
      self.status = :cancelling

      new_invoice = self.dup
      new_invoice.status = :draft
      new_invoice.due_date = Date.current + 5.days if self.due_date < (Date.current + 5.days)

      self.billing_items.each do |item|
        new_item = item.dup
        new_item.members_workouts = item.members_workouts
        new_invoice.billing_items << new_item
        item.members_workouts = []
      end

      new_invoice.save! && self.save! ? new_invoice : self
    end
  end

  def whatsapp_link
    final_link = self.member.whatsapp_link
    message = "Segue o link da fatura: #{self.external_url}"
    final_link = final_link + "?text=" + URI.encode_www_form_component(message)
  end

  def whatsapp_invoice(preview = false)
    final_link = self.member.whatsapp_link
    payer = self.member
    puts payer.alias
    payer_alias = payer.alias.capitalize

    invoice_total =
      ActiveSupport::NumberHelper.number_to_currency(
        self.final_value_cents / 100.0,
        unit: "R$ ",
        separator: ",",
        delimiter: ".",
        precision: 2,
      )

    message = "Oi #{payer_alias}, tudo bem?\nFechamos a sua fatura agora e o total ficou em: #{invoice_total}."

    if preview
      billing_details = []
      n = 1
      self.billing_items.each do |item|
        item_price =
          ActiveSupport::NumberHelper.number_to_currency(
            item.price_cents / 100.0,
            unit: "R$ ",
            separator: ",",
            delimiter: ".",
            precision: 2,
          )
        item_value =
          ActiveSupport::NumberHelper.number_to_currency(
            item.value_cents / 100.0,
            unit: "R$ ",
            separator: ",",
            delimiter: ".",
            precision: 2,
          )
        item_message = "#{n}. #{item.description} | #{item.quantity}x #{item_price} | #{item_value}"
        billing_details << item_message
        n += 1
      end
      billing_details = billing_details.join("\n")
      discount_value =
        ActiveSupport::NumberHelper.number_to_currency(
          self.discount_cents / 100.0,
          unit: "R$ ",
          separator: ",",
          delimiter: ".",
          precision: 2,
        )
      discount_message = "\n#{n}. Desconto: #{discount_value}" if self.discount_cents != 0
      message +=
        "\nDetalhes:\n#{billing_details}#{discount_message}\n\nDaqui a pouco envio a fatura para pagamento, ok?"
    else
      message += "\nDetalhes:\n#{billing_details}#{discount_message}\n\nSegue o link da fatura: #{self.external_url}"
    end

    final_link = final_link + "?text=" + URI.encode_www_form_component(message)
  end

  def mirrorable?
    self.processing? || self.pending? || self.expired?
  end

  def issue_invoice
    self.processing!
  end

  def cancel_invoice
    self.cancelling! unless self.cancelled?
  end

  def set_billing_items_status
    status = self.status
    self.billing_items.each do |item|
      item.status = status
      item.save!
    end
  end

  ransacker :total_value_cents do
    Arel.sql("CONVERT(#{table_name}.total_value_cents, CHAR(8))")
  end
end
