class MembersWorkout < ApplicationRecord
  belongs_to :member
  belongs_to :workout
  belongs_to :billing_item, optional: true

  scope :all_not_billed, -> { where(status: [nil, "canceled", "cancelling", "expired"]) }
  scope :all_reviewed, -> { joins(:workout).where(workout: { reviewed: true }) }
  scope :within, ->(range) { joins(:workout).where(workout: { start_at: range }) }

  def billed?
    %w[draft billed paid].include?(status) && !billing_item.nil?
  end
end
