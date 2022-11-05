class Billing
  def create_billing_items
    members = Member.all
    members.each do |member|
      description_complement = member.responsible_self? ? "" : " | #{member.name}"

      if member.billable? &&
           !member.is_already_in_billing_cycle?(@billing_month.beginning_of_month..@billing_month.end_of_month)
        # Cálculo das mensalidades referentes ao mês seguinte
        if member.has_subscription?
          BillingItem.create!(
            member_id: member.id,
            description: "Mensalidade: #{(@billing_month + 1.month).strftime("%B, %Y")}#{description_complement}",
            reference_date: @billing_month.beginning_of_month,
            status: "draft",
            payable_by: member.responsible,
            price_cents: member.subscription_price,
            quantity: 1,
            billing_type: "subscription",
          )
        end

        # Cálculo dos valores por aulas avulsas
        workouts =
          member.members_workouts.all_not_billed.all_reviewed.within(
            @billing_month.beginning_of_month..@billing_month.end_of_month,
          )
        workoutsCount = workouts.count

        available_workouts = member.workouts_available_in_month(@billing_month.beginning_of_month)

        billable_extra_workouts = workoutsCount - available_workouts # (total de aulas) - (aulas no plano)
        billable_extra_workouts = [0, billable_extra_workouts].max

        replacements = member.replacement_classes
        replacements_for_discount = [billable_extra_workouts, replacements].min
        remaining_replacements = replacements - replacements_for_discount

        if member.has_individual? && billable_extra_workouts > 0
          item =
            BillingItem.create!(
              member_id: member.id,
              description: "Aula Avulsa#{description_complement}",
              price_cents: member.class_price,
              reference_date: @billing_month.beginning_of_month,
              status: "draft",
              payable_by: member.responsible,
              quantity: billable_extra_workouts,
              billing_type: "workout",
            )
          if replacements_for_discount > 0
            BillingItem.create!(
              member_id: member.id,
              description: "Desconto - Aula Reposição#{description_complement}",
              price_cents: -member.class_price,
              reference_date: @billing_month.beginning_of_month,
              status: "draft",
              payable_by: member.responsible,
              quantity: replacements_for_discount,
              billing_type: "replacement",
            )
          end

          # member.replacement_classes = remaining_replacements   ## Ajuste feito para entrar alterar o campo do member.replacement_classes nos callbacks do BillingItem
          member.save!

          workouts.each do |workout|
            workout.status = "billed"
            workout.billing_item = item
            workout.save!
          end
        end
      end
    end
    create_invoices
  end

  def create_invoices
    members = Member.find(BillingItem.all_draft.pluck(:payable_by).uniq)
    members.each do |member|
      items =
        BillingItem.all_draft.where(
          payable_by: member.id,
          invoice_id: nil,
          reference_date: @billing_month.beginning_of_month,
        )
      if items.count > 0
        invoice =
          Invoice.create(
            status: "draft",
            reference_date: @billing_month.beginning_of_month,
            member_id: member.id,
            invoice_type: "billing_cycle",
          )
        items.each do |item|
          item.status = "billed"
          invoice.billing_items << item
          item.save
        end
        invoice.update_totals!
      end
    end
  end

  def run_billing_cycle(month)
    @billing_month = month
    unless Workout
             .all_unreviewed
             .where(start_at: @billing_month.beginning_of_month..@billing_month.end_of_month)
             .count > 0
      create_billing_items
      return true
    end
    return false
  end
end
