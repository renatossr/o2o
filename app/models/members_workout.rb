class MembersWorkout < ApplicationRecord
  STATUS_COLORS = { fresh: "", draft: "primary", pending: "warning", expired: "warning", paid: "success" }
  enum status: { fresh: nil, draft: 0, processing: 10, pending: 11, paid: 12, cancelling: 20, cancelled: 21, expired: 30 }

  belongs_to :member
  belongs_to :workout
  belongs_to :billing_item, optional: true

  scope :not_billed, -> { where(status: [nil, "canceled", "cancelling", "expired"]) }
  scope :reviewed, -> { joins(:workout).where(workout: { reviewed: true }) }
  scope :within, ->(range) { joins(:workout).where(workout: { start_at: range }) }
  scope :subject_to_billing, -> { joins(:workout).where(workout: { gympass: false, cancelled: false }) }
  scope :billable_within, ->(range) { not_billed.reviewed.subject_to_billing.within(range) }
  scope :one_member, -> { where(workout: Workout.one_member) }
  scope :two_members, -> { where(workout: Workout.two_members) }
  scope :three_or_more_members, -> { where(workout: Workout.three_or_more_members) }

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
