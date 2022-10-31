class Billing
  def self.create_billing_items
    members = Member.all
    members.each do |member|
      description_complement = member.responsible_self? ? "" : " | #{member.name}"

      if member.billable?
        avaiable_workouts = member.workouts_available_in_month(DateTime.current.beginning_of_month)
        workoutsCount = member.workouts.all_processed.where(start_at: DateTime.current.beginning_of_month..DateTime.current.end_of_month).count
        billable_workouts = workoutsCount - avaiable_workouts
        billable_workouts = [0, billable_workouts].max
        replacements_for_discount = [billable_workouts, member.replacement_classes].min

        if member.has_subscription?
          BillingItem.create!(
            member_id: member.id,
            description: "Mensalidade#{description_complement}",
            reference_date: Date.current.beginning_of_month,
            status: "draft",
            payable_by: member.responsible,
            price_cents: member.subscription_price,
            quantity: 1,
          )
        end

        if member.has_individual? && billable_workouts > 0
          BillingItem.create!(
            member_id: member.id,
            description: "Aula Avulsa#{description_complement}",
            price_cents: member.class_price,
            reference_date: Date.current.beginning_of_month,
            status: "draft",
            payable_by: member.responsible,
            quantity: billable_workouts,
          )
          if replacements_for_discount > 0
            BillingItem.create!(
              member_id: member.id,
              description: "Aula Reposição#{description_complement}",
              price_cents: -member.class_price,
              reference_date: Date.current.beginning_of_month,
              status: "draft",
              payable_by: member.responsible,
              quantity: replacements_for_discount,
            )
          end
          member.replacement_classes = 0 #TODO: implementar histórico de reposição de aulas
          member.save!
        end
      end
    end
    Billing.create_invoices
  end

  def self.create_invoices
    members = Member.find(BillingItem.all_draft.pluck(:payable_by).uniq)
    members.each do |member|
      items = BillingItem.all_draft.where(payable_by: member.id)
      if items.count > 0
        total_value_cents = 0
        invoice = Invoice.create(status: "draft", reference_date: Date.current.beginning_of_month, member_id: member.id)
        items.each do |item|
          total_value_cents += item.value_cents
          item.invoice_id = invoice.id
          item.status = "invoiced"
          item.save
        end
        invoice.update_totals!
      end
    end
  end

  def self.start_billing_cycle(month)
    month = Date.strptime(month, "%B, %Y")
    puts month
  end
end
