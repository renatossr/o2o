class IuguController < ApplicationController
  skip_before_action :verify_authenticity_token

  def invoice_status_webhook
    authorize Iugu
    iugu_invoice_id = params["data"]["id"]
    status = params["data"]["status"]
    paid_at = params["data"]["paid_at"]
    paid_cents = params["data"]["paid_cents"]
    payment_method = params["data"]["payment_method"]

    invoice = Invoice.find_by(external_id: iugu_invoice_id)
    if invoice
      invoice.status = status
      invoice.paid_at = paid_at
      invoice.paid_cents = paid_cents
      invoice.payment_method = payment_method
      invoice.save!
    end
  end
end
