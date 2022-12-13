namespace :sync do
  desc "Sync Events"
  task events: :environment do
    puts "synching events..."
    GCalendar.syncEvents(additive: true)
    puts "sync done!"
  end
end
