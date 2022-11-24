class PayablesController < ApplicationController
  before_action :set_payable, only: %i[show edit update]
  before_action :sanitize_currency, only: %i[update create]

  def index
    authorize Payable
    @q = Payable.ransack(params[:q])
    @q.sorts = ["reference_date desc"]
    @payables = @q.result.includes(:coach)
    @payables = @payables.page(params[:page])
  end

  def create
    reference_date = payable_params[:reference_date] || Date.current.beginning_of_month
    @billing = Billing.find_or_create_by(reference_date: reference_date)
    @payable = @billing.payables.build(payable_params)
    authorize @payable
    @payable.status = "draft"
    @payable.payable_type = "manual"
    @payable.reference_date = Date.current.beginning_of_month
    if @payable.save
      @payable.update_totals!
      if params[:previous_request]
        uri = URI(params[:previous_request])
        uri.query = "payable_tab_show=true" if uri.query.present?
        redirect_to uri.to_s
      else
        redirect_to payables_path
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def new
    @payable = Payable.new
    authorize @payable
  end

  def edit
    authorize @payable
    redirect_to payable_path(@payable) if @payable.status != "draft"
  end

  def show
    authorize @payable
  end

  def update
    authorize @payable
    if @payable.update(payable_params)
      @payable.update_totals!
      @billing = @invoice.billing
      if params[:previous_request]
        uri = URI(params[:previous_request])
        uri.query = "payable_tab_show=true" if uri.query.present?
        redirect_to uri.to_s
      else
        redirect_to billing_path(@billing, params: { payable_tab_show: true })
      end
    else
      render :payable_events, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @payable
  end

  def confirm
    authorize Payable
    ids_to_confirm = params[:payables_in_cycle].select { |k, v| v == "1" }.keys
    ids_to_confirm.each { |id| payable = Payable.find(id).issue_payable if id != "confirm" }
    @billing = Billing.find(params[:id])
    redirect_to billing_path(@billing, params: { payable_tab_show: true })
  end

  private

  def sanitize_currency
    params[:payable][:discount_cents] = (params[:payable][:discount_cents].sub(".", "").sub(",", ".").to_d * 100).to_i
    if params[:payable][:payable_items_attributes].present?
      params[:payable][:payable_items_attributes].each do |key, value|
        value[:price_cents] = (value[:price_cents].sub(".", "").sub(",", ".").to_d * 100).to_i if value[
          :price_cents
        ].present?
      end
    end
  end

  def set_payable
    @payable = Payable.find(params[:id])
    @payable_items = @payable.payable_items
  end

  # Only allow a list of trusted parameters through.
  def payable_params
    params.require(:payable).permit(
      :id,
      :coach_id,
      :reference_date,
      :discount_cents,
      payable_items_attributes: %i[id coach_id description price_cents quantity payable_type _destroy],
    )
  end
end
