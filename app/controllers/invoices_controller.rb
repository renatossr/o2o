class InvoicesController < ApplicationController
  before_action :set_invoice, only: %i[show edit update]
  before_action :sanitize_currency, only: %i[update create]

  def index
    authorize Invoice
    search_param =
      params[:q][
        :member_first_name_or_member_last_name_or_reference_date_or_status_or_total_value_cents_cont_any
      ] if params[:q].present?
    if search_param && search_param.kind_of?(Array) == false
      words = search_param.split(" ")
      params[:q][
        :member_first_name_or_member_last_name_or_reference_date_or_status_or_total_value_cents_cont_any
      ] = words
    end
    @q = Invoice.ransack(params[:q])
    @q.sorts = ["reference_date desc", "id desc"]
    @invoices = @q.result.includes(:member)
    @invoices = @invoices.page(params[:page])
  end

  def new
    @invoice = Invoice.new(member_id: params[:member_id], due_date: Date.current + 5.days)
    authorize @invoice
  end

  def new_from_workout
    authorize Invoice
    @workout = Workout.find(params[:workout_id])
    Invoice.create_from_workout(@workout)
    redirect_to workouts_path
  end

  def create
    authorize Invoice
    reference_date = invoice_params[:reference_date] || Date.current.beginning_of_month
    @billing = Billing.find_or_create_by(reference_date: reference_date)
    @invoice = @billing.invoices.build(invoice_params)
    @invoice.status = :draft
    @invoice.invoice_type = "manual"
    @invoice.reference_date = reference_date
    if @billing.save
      @invoice.update_totals!
      if params[:previous_request]
        uri = URI(params[:previous_request])
        uri.query = "invoice_tab_show=true" if uri.query.present?
        redirect_to uri.to_s
      else
        redirect_to invoices_path
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    authorize @invoice
  end

  def edit
    authorize @invoice
    redirect_to show_invoice_path(@invoice) unless @invoice.draft?
  end

  def update
    authorize @invoice
    if @invoice.update(invoice_params)
      @invoice.update_totals!
      @billing = @invoice.billing
      if params[:previous_request]
        uri = URI(params[:previous_request])
        uri.query = "invoice_tab_show=true" if uri.query.present?
        redirect_to uri.to_s
      else
        redirect_to billing_path(@billing, params: { invoice_tab_show: true })
      end
    else
      render :process_events, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @invoice
  end

  def cancel
    @invoice = Invoice.find(invoice_params[:id])
    authorize @invoice
    @invoice.cancel_invoice
    redirect_to invoice_path(@invoice)
  end

  def confirm_all
    authorize Invoice
    ids_to_confirm = params[:invoices_in_cycle].select { |k, v| v == "1" }.keys
    ids_to_confirm.each { |id| invoice = Invoice.find(id).issue_invoice if id != "confirm" }
    @billing = Billing.find(params[:id])
    redirect_to billing_path(@billing, params: { invoice_tab_show: true })
  end

  def confirm
    @invoice = Invoice.find(params[:invoice][:id])
    authorize @invoice
    @invoice.issue_invoice
    redirect_to @invoice
  end

  private

  def sanitize_currency
    params[:invoice][:discount_cents] = (params[:invoice][:discount_cents].sub(".", "").sub(",", ".").to_d * 100).to_i
    if params[:invoice][:billing_items_attributes].present?
      params[:invoice][:billing_items_attributes].each do |key, value|
        value[:price_cents] = (value[:price_cents].sub(".", "").sub(",", ".").to_d * 100).to_i if value[
          :price_cents
        ].present?
      end
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
      :due_date,
      :discount_cents,
      billing_items_attributes: %i[id description price_cents quantity billing_type member_id payable_by _destroy],
    )
  end
end
