class BillingController < ApplicationController
  def index
    @invoices = Invoice.all.includes(:items)
  end

  def bill
    members = Member.all
    members.each do |member|
      totalValueCents = 0
      if member.subscription_price > 0 || member.class_price > 0
        invoice = Invoice.new(
          member_id: member.id,
          reference_date: Date.current.beginning_of_month,
          status: 'draft'
        )
        if invoice.save
          if member.subscription_price > 0
            item = Item.new(
              member_id: member.id,
              description: "Mensalidade",
              reference_date: Date.current.beginning_of_month,
              status: "draft",
              invoice_id: invoice.id,
              payable_by: member.id,
              total_cents: member.subscription_price
            )
            if item.save
              totalValueCents += item.total_cents
            end
          end
      
          workoutsCount = member.workouts.where(start_at: DateTime.current.beginning_of_month..DateTime.current.end_of_month).count
          if member.class_price > 0 && workoutsCount > 0
            totalCents = workoutsCount*member.class_price
            item = Item.new(
              member_id: member.id,
              description: "#{workoutsCount}x Aula (R$ #{(member.class_price).to_d/100})",
              reference_date: Date.current.beginning_of_month,
              status: "draft",
              invoice_id: invoice.id,
              payable_by: member.id,
              total_cents: totalCents
            )
            if item.save
              totalValueCents += item.total_cents
            end

            invoice.total_value_cents = totalValueCents
            invoice.save
          end
        end
      end
    end
  end
end
