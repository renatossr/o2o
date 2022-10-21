class BillingController < ApplicationController
  def index
    @invoices = Invoice.all.includes(:billing_items)
  end

  def bill
    Billing.create_billing_items
    redirect_to action: "index"
  end
end
