class BillingController < ApplicationController
  def dashboard
    @invoices = Invoice.all.includes(:billing_items).page(params[:page]).per(50)
  end

  def billing_cycle
    @selected_date = Date.today.beginning_of_month.strftime("%B, %Y")
    @selected_date = params[:billing_cycle][:cycle] if params[:billing_cycle]
    reference_date = Date.strptime(@selected_date, "%B, %Y")
    @invoices = Invoice.all.where(reference_date: reference_date).page(params[:page]).per(50)
  end

  def start_cycle
    billing_cycle = Billing.new
    if billing_cycle.run_billing_cycle(Date.strptime(billing_cycle_params[:cycle], "%B, %Y"))
      redirect_to action: "billing_cycle", params: { billing_cycle: { cycle: billing_cycle_params[:cycle] } }
    else
      redirect_to action: "billing_cycle",
                  notice: "Aulas pendentes de confirmação para o ciclo de faturamento",
                  params: {
                    billing_cycle: {
                      cycle: billing_cycle_params[:cycle],
                    },
                  }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.

  def billing_cycle_params
    params.require(:billing_cycle).permit(:cycle)
  end
end
