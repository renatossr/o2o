namespace :iugu do
  desc "Send Invoices to iugu"
  task issue_invoices: :environment do
    puts "Issuing invoices..."
    invoices = Invoice.all_processing
    Iugu.create_invoices(invoices)
    puts "Issuing done!"
  end

  desc "Cancel Invoices at iugu"
  task cancel_invoices: :environment do
    puts "Canceling invoices..."
    invoices = Invoice.all_cancelling
    Iugu.cancel_invoices(invoices)
    puts "Canceling done!"
  end
end
