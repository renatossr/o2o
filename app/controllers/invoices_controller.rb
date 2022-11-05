class InvoicesController < ApplicationController
  before_action :set_invoice, only: %i[show edit update]
  before_action :sanitize_currency, only: %i[update create]

  def index
  end

  def create
    @invoice = Invoice.new(invoice_params)
    @invoice.status = "draft"
    @invoice.invoice_type = "manual"
    @invoice.reference_date = Date.current.beginning_of_month
    if @invoice.billing_items.present? && @invoice.save!
      @invoice.update_totals!
      if params[:previous_request]
        redirect_to params[:previous_request]
      else
        redirect_to billing_dashboard_path
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def new
    @invoice = Invoice.new
  end

  def new_from_workout
    @workout = Workout.find(params[:workout_id])
    @invoice = Invoice.new.new_from_workout(workout)
  end

  def edit
    redirect_to show_invoice_path(@invoice) if @invoice.status != "draft"
  end

  def show
  end

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

  def destroy
  end

  def cancel
    @invoice = Invoice.find(invoice_params[:id])
    @invoice.cancel_invoice
    redirect_to invoice_path(@invoice)
  end

  def confirm
    ids_to_confirm = params[:invoices_in_cycle].select { |k, v| v == "1" }.keys
    ids_to_confirm.each { |id| invoice = Invoice.find(id).issue_invoice if id != "confirm" }
    redirect_to controller: :billing,
                action: :billing_cycle,
                params: {
                  billing_cycle: {
                    cycle: params[:billing_cycle][:cycle],
                  },
                }
  end

  private

  def sanitize_currency
    params[:invoice][:discount_cents] = (params[:invoice][:discount_cents].sub(".", "").sub(",", ".").to_d * 100).to_i
    params[:invoice][:billing_items_attributes].each do |key, value|
      value[:price_cents] = (value[:price_cents].sub(".", "").sub(",", ".").to_d * 100).to_i
    end
  end

  def set_invoice
    @invoice = Invoice.find(params[:id])
    @invoice_items = @invoice.billing_items
  end

  # Only allow a list of trusted parameters through.
  def invoice_params
    params.require(:invoice).permit(
      :id,
      :member_id,
      :discount_cents,
      billing_items_attributes: %i[id description price_cents quantity billing_type member_id payable_by _destroy],
    )
  end
end
