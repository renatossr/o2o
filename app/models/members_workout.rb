class MembersWorkout < ApplicationRecord
  belongs_to :member
  belongs_to :workout
  belongs_to :billing_item, optional: true

  scope :not_billed, -> { where.not(status: "billed") }
  scope :all_status_nil, -> { where(status: nil) }
  scope :all_not_billed, -> { all_status_nil.or(not_billed) }
  scope :all_reviewed, -> { joins(:workout).where(workout: { reviewed: true }) }
  scope :within, ->(range) { joins(:workout).where(workout: { start_at: range }) }
end
