class BillingController < ApplicationController
  def index
    @invoices = Invoice.all
  end

  def bill
    members = Member.all
    members.each do |member|
      invoices = member.invoices.where()
    end
  end
end
