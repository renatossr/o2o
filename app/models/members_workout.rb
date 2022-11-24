class MembersWorkout < ApplicationRecord
  STATUS_COLORS = { fresh: "", draft: "primary", pending: "warning", expired: "warning", paid: "success" }
  enum status: {
         fresh: nil,
         draft: 0,
         processing: 10,
         pending: 11,
         paid: 12,
         cancelling: 20,
         cancelled: 21,
         expired: 30,
       }

  belongs_to :member
  belongs_to :workout
  belongs_to :billing_item, optional: true

  scope :all_not_billed, -> { where(status: [nil, "canceled", "cancelling", "expired"]) }
  scope :all_reviewed, -> { joins(:workout).where(workout: { reviewed: true }) }
  scope :within, ->(range) { joins(:workout).where(workout: { start_at: range }) }
  scope :all_billable_within, ->(range) { all_not_billed.all_reviewed.within(range) }

  def status_color
    STATUS_COLORS[status&.to_sym] || "secondary"
  end

  def billed?
    %w[fresh cancelled expired].include?(status) == false && billing_item.present?
  end

  def start_at
    workout.start_at
  end
end
