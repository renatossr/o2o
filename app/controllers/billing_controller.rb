class BillingController < ApplicationController
  def index
    @invoices = Invoice.all
  end

  def bill
  end
end
