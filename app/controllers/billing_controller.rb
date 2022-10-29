class BillingController < ApplicationController
  before_action :set_member, only: %i[show edit]

  def index
    @invoices = Invoice.all.includes(:billing_items).page(params[:page])
  end

  def bill
    Billing.create_billing_items
    redirect_to action: "index"
  end

  def show
  end

  def edit
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_member
    @invoice = Invoice.find(params[:id])
    @invoice_items = @invoice.billing_items
  end
end
