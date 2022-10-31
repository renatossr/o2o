class BillingController < ApplicationController
  before_action :set_member, only: %i[show edit update]
  before_action :sanitize_currency, only: %i[update]

  def dashboard
    @invoices = Invoice.all.includes(:billing_items).page(params[:page])
  end

  def billing_cycle
    @selected_date = (Date.today - 1.month).end_of_month.strftime("%B, %Y")
    if params[:billing_cycle]
      @selected_date = params[:billing_cycle][:cycle]
      reference_date = Date.strptime(params[:billing_cycle][:cycle], "%B, %Y")
      @invoices = Invoice.all.where(reference_date: reference_date).page(params[:page])
    end
  end

  def start_cycle
    Billing.start_billing_cycle(billing_cycle_params[:cycle])
    redirect_to action: "billing_cycle"
  end

  def bill
    Billing.create_billing_items
    redirect_to action: "dashboard"
  end

  def show
  end

  def edit
  end

  # PATCH/PUT /proc_event/1
  def update
    if @invoice.update(invoice_params)
      @invoice.update_totals!
      if params[:previous_request]
        redirect_to params[:previous_request]
      else
        redirect_to billing_dashboard_path
      end
    else
      render :process_events, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_member
    @invoice = Invoice.find(params[:id])
    @invoice_items = @invoice.billing_items
  end

  # Only allow a list of trusted parameters through.
  def invoice_params
    params.require(:invoice).permit(:member_id, :discount_cents, billing_items_attributes: %i[id description price_cents quantity member_id payable_by _destroy])
  end

  def billing_cycle_params
    params.require(:billing_cycle).permit(:cycle)
  end

  def sanitize_currency
    params[:invoice][:discount_cents] = (params[:invoice][:discount_cents].sub(".", "").sub(",", ".").to_d * 100).to_i
    params[:invoice][:billing_items_attributes].each { |key, value| value[:price_cents] = (value[:price_cents].sub(".", "").sub(",", ".").to_d * 100).to_i }
  end
end
