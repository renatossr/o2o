class Billing < ApplicationRecord
  STATUS_COLORS = { draft: "primary", closed: "success" }
  enum status: { draft: 0, closed: 2 }

  has_many :invoices
  has_many :payables

  accepts_nested_attributes_for :invoices, :payables

  before_save :update_totals

  def status_color
    STATUS_COLORS[status&.to_sym] || "secondary"
  end

  def editable?
    reference_date < Date.current.beginning_of_month && draft?
  end

  def has_draft_items?
    invoices.draft.count > 0 || payables.draft.count > 0 || closed?
  end

  def closable?
    !has_draft_items?
  end

  def processable?
    Member.all_billable_within(range).count > 0
  end

  def range
    (reference_date.beginning_of_month..reference_date.end_of_month)
  end

  def update_totals
    self.revenue_cents = 0
    self.invoices.each { |invoice| self.revenue_cents += (invoice.total_value_cents || 0) }
    self.cost_cents = 0
    self.payables.each { |payable| self.cost_cents += (payable.total_value_cents || 0) }
  end

  def update_totals!
    self.revenue_cents = 0
    self.invoices.each { |invoice| self.revenue_cents += (invoice.total_value_cents || 0) }
    self.cost_cents = 0
    self.payables.each { |payable| self.cost_cents += (payable.total_value_cents || 0) }
    self.save!
  end

  def run_billing_cycle
    unless closed?
      invoice_all_members
      create_payables_all_coaches
      if save!
        update_totals!
        Billing.find_or_create_by!(reference_date: reference_date.beginning_of_month + 1.month) # Opens following month's cycle if not open from manual invoicing
        return true
      end
    end
    return false
  end

  def invoice_all_members
    members = Member.all_billable_within(range)
    members.each do |member|
      puts "Member ##{member.id} billable"
      invoice_member(member)
    end
  end

  def invoice_member(member)
    invoice =
      invoices.build(
        status: :draft,
        reference_date: reference_date.beginning_of_month,
        due_date: reference_date.end_of_month + 5.days,
        member_id: member.id,
        invoice_type: "billing_cycle",
      )

    billing_items = []
    member.beneficiaries.each do |beneficiary|
      collected_billing_items = collect_billing_items(beneficiary)
      billing_items += collected_billing_items unless collected_billing_items.nil?
    end

    invoice.billing_items += billing_items if billing_items.count > 0
  end

  def collect_billing_items(beneficiary)
    billing_items = []

    billable_workouts = beneficiary.members_workouts.billable_within(range)
    billable_extra_workouts_count = beneficiary.billable_extra_workouts_count(reference_date)
    replacements_for_discount = beneficiary.replacements_for_discount(billable_extra_workouts_count)

    billing_items += create_subscription_billing_item(beneficiary) if beneficiary.has_billable_subscription?
    billing_items +=
      create_individual_class_billing_items(
        beneficiary,
        billable_workouts,
        billable_extra_workouts_count,
      ) if beneficiary.has_individual? && billable_extra_workouts_count > 0
    billing_items +=
      create_discount_for_replacement_classes_billing_items(
        beneficiary,
        replacements_for_discount,
      ) if replacements_for_discount > 0
    billing_items
  end

  def create_subscription_billing_item(beneficiary)
    billing_items = []
    item =
      BillingItem.new(
        member_id: beneficiary.id,
        description:
          "Mensalidade: #{I18n.l((reference_date + 1.month), format: "%B, %Y")}#{description_complement(beneficiary)}",
        reference_date: reference_date.beginning_of_month + 1.month,
        status: :draft,
        payer: beneficiary,
        price_cents: beneficiary.subscription_price,
        quantity: 1,
        billing_type: "subscription",
      )
    billing_items << item
  end

  def create_individual_class_billing_items(beneficiary, billable_workouts, billable_extra_workouts_count)
    billing_items = []
    item =
      BillingItem.new(
        member_id: beneficiary.id,
        description: "Aula Avulsa#{description_complement(beneficiary)}",
        price_cents: beneficiary.class_price,
        reference_date: reference_date.beginning_of_month,
        status: :draft,
        payer: beneficiary,
        quantity: billable_extra_workouts_count,
        billing_type: "workout",
      )
    item.members_workouts = billable_workouts
    billing_items << item
  end

  def create_discount_for_replacement_classes_billing_items(beneficiary, replacements_for_discount)
    billing_items = []
    item =
      BillingItem.new(
        member_id: beneficiary.id,
        description: "Desconto - Aula Reposição#{description_complement(beneficiary)}",
        price_cents: -beneficiary.class_price,
        reference_date: reference_date.beginning_of_month,
        status: :draft,
        payer: beneficiary,
        quantity: replacements_for_discount,
        billing_type: "replacement",
      )
    billing_items << item
  end

  def description_complement(beneficiary)
    description_complement = beneficiary.responsible_self? ? "" : " | #{beneficiary.name}"
  end

  ############################ Coach Payable logic #############################################

  def create_payables_all_coaches
    coaches = Coach.all
    coaches.each do |coach|
      if coach.payable? && !coach.is_already_in_billing_cycle?(range)
        puts "Coach ##{coach.id} payable"
        create_payable_to_coach(coach)
      end
    end
  end

  def create_payable_to_coach(coach)
    payable =
      payables.build(
        reference_date: reference_date.beginning_of_month,
        status: :draft,
        coach: coach,
        payable_type: "billing_cycle",
      )

    collected_payable_items = collect_payable_items(coach)

    payable.payable_items += collected_payable_items if collected_payable_items.count > 0
  end

  def collect_payable_items(coach)
    payable_items = []

    payable_workouts = coach.workouts.all.payable_within(range)
    payable_wokouts_count = payable_workouts.count

    payable_items += create_fixed_salary_payable_item(coach) if coach.has_fixed_salary?
    payable_items +=
      create_individual_class_payable_items(coach, payable_workouts, payable_wokouts_count) if coach.has_individual? &&
      payable_wokouts_count > 0
    payable_items
  end

  def create_fixed_salary_payable_item(coach)
    payable_items = []
    item =
      PayableItem.new(
        coach: coach,
        description: "Salário: #{I18n.l(reference_date, format: "%B, %Y")}",
        reference_date: reference_date.beginning_of_month,
        price_cents: coach.pay_fixed,
        quantity: 1,
        value_cents: coach.pay_fixed,
        payable_type: "fixed",
      )
    payable_items << item
  end

  def create_individual_class_payable_items(coach, payable_workouts, payable_wokouts_count)
    payable_items = []
    item =
      PayableItem.new(
        coach: coach,
        description: "Aula",
        price_cents: coach.pay_per_workout,
        reference_date: reference_date.beginning_of_month,
        quantity: payable_wokouts_count,
        value_cents: coach.pay_per_workout * payable_wokouts_count,
        payable_type: "workout",
      )
    item.workouts = payable_workouts
    payable_items << item
  end
end
