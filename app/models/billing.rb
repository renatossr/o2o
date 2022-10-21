class Billing
  def self.create_billing_items
    members = Member.all
    members.each do |member|
      description_complement =
        member.responsible_self? ? "" : " | #{member.name}"
      if member.billable?
        if member.has_subscription?
          BillingItem.create(
            member_id: member.id,
            description: "Mensalidade#{description_complement}",
            reference_date: Date.current.beginning_of_month,
            status: "draft",
            payable_by: member.responsible,
            total_cents: member.subscription_price,
          )
        end

        if member.has_individual?
          workoutsCount =
            member
              .workouts
              .where(
                start_at:
                  DateTime.current.beginning_of_month..DateTime.current.end_of_month,
              )
              .count
          if workoutsCount > 0
            totalCents = workoutsCount * member.class_price
            BillingItem.create(
              member_id: member.id,
              description:
                "#{workoutsCount}x Aula (R$ #{(member.class_price).to_d / 100})#{description_complement}",
              reference_date: Date.current.beginning_of_month,
              status: "draft",
              payable_by: member.responsible,
              total_cents: totalCents,
            )
          end
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
        invoice =
          Invoice.create(
            status: "draft",
            reference_date: Date.current.beginning_of_month,
            member_id: member.id,
          )
        items.each do |item|
          total_value_cents += item.total_cents
          item.invoice_id = invoice.id
          item.status = "invoiced"
          item.save
        end
        invoice.update_totals!
      end
    end
  end
end
