namespace :sync do
  desc "Sync Events"
  task events: :environment do
    puts "synching events..."
    GCalendar.syncEvents
    puts "sync done!"
  end
end
