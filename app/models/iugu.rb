class Iugu
  require "uri"
  require "net/http"
  require "openssl"

  def self.send_post_api_call(api, body)
    api_key = Rails.application.credentials.iugu.api_key
    url = URI("https://api.iugu.com/v1/#{api}?api_token=#{api_key}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["accept"] = "application/json"
    request["content-type"] = "application/json"
    request.body = body

    response = http.request(request)
  end

  def self.send_put_api_call(api)
    api_key = Rails.application.credentials.iugu.api_key
    url = URI("https://api.iugu.com/v1/#{api}?api_token=#{api_key}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Put.new(url)
    request["accept"] = "application/json"
    request["content-type"] = "application/json"

    response = http.request(request)
  end

  def self.create_invoice(invoice)
    api = "invoices"
    iugu_invoice = {
      items: [],
      payable_with: "pix",
      email: "renato.fairbanks@gmail.com",
      due_date: invoice.due_date,
      discount_cents: invoice.discount_cents,
    }
    invoice
      .billing_items
      .select(:description, :quantity, :price_cents)
      .each do |item|
        iugu_invoice[:items].push(description: item.description, quantity: item.quantity, price_cents: item.price_cents)
      end
    response = Iugu.send_post_api_call(api, iugu_invoice.to_json)

    if response.is_a? Net::HTTPSuccess
      body = JSON.parse(response.read_body)

      invoice.external_id = body["id"]
      invoice.external_url = body["secure_url"]
      invoice.status = body["status"]
      invoice.save!
    end
  end

  def self.cancel_invoice(invoice)
    invoice_id = invoice.external_id
    puts invoice_id
    api = "invoices/#{invoice_id}/cancel"
    response = Iugu.send_put_api_call(api)

    if response.is_a? Net::HTTPSuccess
      body = JSON.parse(response.read_body)

      invoice.status = body["status"]
      invoice.save!
    end
  end

  def self.create_invoices(invoices)
    invoices.each { |invoice| Iugu.create_invoice(invoice) }
  end

  def self.cancel_invoices(invoices)
    invoices.each { |invoice| Iugu.cancel_invoice(invoice) }
  end
end
