class Workout < ApplicationRecord
  has_many :members_workouts
  has_many :members, through: :members_workouts
  belongs_to :coach, optional: true
  belongs_to :calendar_event, optional: true
  belongs_to :billing_item, optional: true
  belongs_to :payable_item, optional: true

  accepts_nested_attributes_for :members

  scope :unreviewed, -> { where(reviewed: false) }
  scope :reviewed, -> { where(reviewed: true) }
  scope :no_payable_item, -> { where(payable_item_id: nil) }
  scope :within, ->(range) { where(start_at: range) }
  scope :billable_within, ->(range) { not_billed.reviewed.within(range) }
  scope :payable_within, ->(range) { where(cancelled: false).where.not(coach_id: nil).no_payable_item.reviewed.within(range) }
  scope :one_member, -> { joins(:members_workouts).group("workouts.id").having("count(members_workouts.workout_id) = 1") }
  scope :two_members, -> { joins(:members_workouts).group("workouts.id").having("count(members_workouts.workout_id) = 2") }
  scope :three_or_more_members, -> { joins(:members_workouts).group("workouts.id").having("count(members_workouts.workout_id) > 2") }

  def mark_reviewed
    self.reviewed = true
    if self.members.count > 0 && self.with_replacement?
      self.members.each do |member|
        member.replacement_classes += 1
        member.save!
      end
    end
    self.save
  end

  def mark_replacement
    self.with_replacement = true
    self.save
  end

  def title
    self.calendar_event.title
  end

  def has_not_loyal_billed_member
    result = false
    self.members_workouts.each do |member_workout|
      if member_workout.billing_item_id == nil && member_workout.member.loyal == false
        result = true
        break
      end
    end
    result
  end
end
