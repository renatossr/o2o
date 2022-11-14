class Workout < ApplicationRecord
  has_many :members_workouts
  has_many :members, through: :members_workouts
  belongs_to :coach, optional: true
  belongs_to :calendar_event, optional: true
  belongs_to :billing_item, optional: true
  belongs_to :payable_item, optional: true

  accepts_nested_attributes_for :members

  scope :all_processed, -> { where(status: %w[cancelled confirmed]) }
  scope :all_unreviewed, -> { where(reviewed: false) }
  scope :all_reviewed, -> { where(reviewed: true) }
  scope :all_no_payable, -> { where(payable_item_id: nil) }
  scope :within, ->(range) { where(start_at: range) }
  scope :all_payable_within, ->(range) { where.not(status: "cancelled").all_no_payable.all_reviewed.within(range) }

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
