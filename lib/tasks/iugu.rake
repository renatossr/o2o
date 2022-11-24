namespace :iugu do
  desc "Send Invoices to iugu"
  task issue_invoices: :environment do
    puts "Issuing invoices..."
    invoices = Invoice.processing
    Iugu.create_invoices(invoices)
    puts "Issuing done!"
  end

  desc "Cancel Invoices at iugu"
  task cancel_invoices: :environment do
    puts "Cancelling invoices..."
    invoices = Invoice.cancelling
    Iugu.cancel_invoices(invoices)
    puts "Cancelling done!"
  end
end
