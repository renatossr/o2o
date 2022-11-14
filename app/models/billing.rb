class Billing
  def run_billing_cycle(month)
    unless Workout.all_unreviewed.where(start_at: month.beginning_of_month..month.end_of_month).count > 0
      invoice_all_members(month)
      create_payables_all_coaches(month)
      return true
    end
    return false
  end

  def invoice_all_members(month)
    members = Member.all
    members.each do |member|
      if member.billable? && !member.is_already_in_billing_cycle?(month.beginning_of_month..month.end_of_month)
        invoice_member(member, month)
      end
    end
  end

  def invoice_member(member, month)
    invoice =
      Invoice.new(
        status: "draft",
        reference_date: month.beginning_of_month,
        due_date: month.end_of_month + 5.days,
        member_id: member.id,
        invoice_type: "billing_cycle",
      )

    billing_items = []
    member.beneficiaries.each do |beneficiary|
      collected_billing_items = collect_billing_items(beneficiary, month)
      billing_items += collected_billing_items unless collected_billing_items.nil?
    end
    if billing_items.count > 0
      invoice.billing_items += billing_items
      invoice.save!
    end
  end

  def collect_billing_items(beneficiary, month)
    billing_items = []

    billable_workouts =
      beneficiary.members_workouts.all_not_billed.all_reviewed.within(month.beginning_of_month..month.end_of_month)

    billable_extra_workouts_count = beneficiary.billable_extra_workouts_count(month)
    replacements_for_discount = beneficiary.replacements_for_discount(billable_extra_workouts_count)

    billing_items += create_subscription_billing_item(beneficiary, month) if beneficiary.has_subscription?
    billing_items +=
      create_individual_class_billing_items(
        beneficiary,
        month,
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

  def create_subscription_billing_item(beneficiary, month)
    billing_items = []
    item =
      BillingItem.new(
        member_id: beneficiary.id,
        description: "Mensalidade: #{(month + 1.month).strftime("%B, %Y")}#{description_complement(beneficiary)}",
        reference_date: month.beginning_of_month + 1.month,
        status: "draft",
        payer: beneficiary,
        price_cents: beneficiary.subscription_price,
        quantity: 1,
        billing_type: "subscription",
      )
    billing_items << item
  end

  def create_individual_class_billing_items(beneficiary, month, billable_workouts, billable_extra_workouts_count)
    billing_items = []
    item =
      BillingItem.new(
        member_id: beneficiary.id,
        description: "Aula Avulsa#{description_complement(beneficiary)}",
        price_cents: beneficiary.class_price,
        reference_date: month.beginning_of_month,
        status: "draft",
        payer: beneficiary,
        quantity: billable_extra_workouts_count,
        billing_type: "workout",
      )
    item.members_workouts = billable_workouts
    billing_items << item
  end

  def create_discount_for_replacement_classes_billing_items(beneficiary, month, replacements_for_discount)
    billing_items = []
    item =
      BillingItem.new(
        member_id: beneficiary.id,
        description: "Desconto - Aula Reposição#{description_complement(beneficiary)}",
        price_cents: -beneficiary.class_price,
        reference_date: month.beginning_of_month,
        status: "draft",
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

  def create_payables_all_coaches(month)
    coaches = Coach.all
    coaches.each do |coach|
      if coach.payable? && !coach.is_already_in_billing_cycle?(month.beginning_of_month..month.end_of_month)
        puts "Coach payable"
        create_payable_to_coach(coach, month)
      end
    end
  end

  def create_payable_to_coach(coach, month)
    payable = Payable.new(reference_date: month.beginning_of_month, coach: coach)

    collected_payable_items = collect_payable_items(coach, month)

    if collected_payable_items.count > 0
      payable.payable_items += collected_payable_items
      payable.save!
    end
  end

  def collect_payable_items(coach, month)
    payable_items = []

    payable_workouts = coach.workouts.all_payable_within(month.beginning_of_month..month.end_of_month)
    payable_wokouts_count = payable_workouts.count

    payable_items += create_fixed_salary_payable_item(coach, month) if coach.has_fixed_salary?
    payable_items +=
      create_individual_class_payable_items(
        coach,
        month,
        payable_workouts,
        payable_wokouts_count,
      ) if coach.has_individual? && payable_wokouts_count > 0
    payable_items
  end

  def create_fixed_salary_payable_item(coach, month)
    payable_items = []
    item =
      PayableItem.new(
        coach: coach,
        description: "Salário: #{(month).strftime("%B, %Y")}",
        reference_date: month.beginning_of_month,
        price_cents: coach.pay_fixed,
        quantity: 1,
        value_cents: coach.pay_fixed,
        payable_type: "fixed",
      )
    payable_items << item
  end

  def create_individual_class_payable_items(coach, month, payable_workouts, payable_wokouts_count)
    payable_items = []
    item =
      PayableItem.new(
        coach: coach,
        description: "Aula",
        price_cents: coach.pay_per_workout,
        reference_date: month.beginning_of_month,
        quantity: payable_wokouts_count,
        value_cents: coach.pay_per_workout * payable_wokouts_count,
        payable_type: "workout",
      )
    item.workouts = payable_workouts
    payable_items << item
  end
end
