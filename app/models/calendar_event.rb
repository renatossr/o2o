class CalendarEvent < ApplicationRecord
  has_one :workout

  scope :all_unprocessed, -> { where(processed: false) }
end
