class BillingsController < ApplicationController
  def dashboard
    authorize Billing
    @invoices = Invoice.all.includes(:billing_items).page(params[:page]).per(50)
  end

  def index
    authorize Billing
    @billings = Billing.all.order("reference_date desc").page(params[:page])
  end

  def new
    @billing_cycle = Billing.new
    authorize @billing
  end

  def show
    @billing = Billing.find(params[:id])
    authorize @billing
    @selected_date = @billing.reference_date.strftime("%B, %Y")
    @invoices = @billing.invoices.order("status asc, created_at desc").page(params[:page]).per(50)
    @payables = @billing.payables.order("status asc, created_at desc").page(params[:page]).per(50) #FIX page para cada tipo de paginação
    @draft_invoice_count = @billing.invoices.draft.count
    @draft_payable_count = @billing.payables.draft.count

    @payable_tab_show = params[:payable_tab_show] ? "show active" : ""
    @invoice_tab_show = params[:invoice_tab_show] ? "show active" : ""
  end

  def start_cycle
    @billing = Billing.find(params[:id])
    authorize @billing
    if @billing.run_billing_cycle
      @payable_tab_show = params[:payable_tab_show] ? "show active" : ""
      @invoice_tab_show = params[:invoice_tab_show] ? "show active" : ""
      redirect_to @billing
    else
      flash[:error] = "Não foi possível rodar o faturamento para o mês!"
      redirect_to @billing
    end
  end

  def close_cycle
    @billing = Billing.find(params[:id])
    authorize @billing
    if @billing.closable? && @billing.closed!
      redirect_to @billing
    else
      flash[:error] = "Não foi possível fechar o faturamento do mês!"
      redirect_to @billing
    end
  end

  private

  def billing_cycle_params
    params.require(:billing_cycle).permit(:cycle)
  end
end
