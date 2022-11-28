class BillingItem < ApplicationRecord
  enum status: { draft: 0, processing: 10, pending: 11, paid: 12, cancelling: 20, cancelled: 21, expired: 30 }

  belongs_to :invoice, optional: true
  belongs_to :member
  belongs_to :payer, class_name: "Member", foreign_key: :payable_by
  has_many :members_workouts

  validates :description, presence: true
  validates :price_cents, numericality: { only_integer: true }
  validates :quantity, numericality: { only_integer: true }

  before_validation :populate_member_and_payer, if: proc { self.invoice.present? }
  after_create :decrease_member_replacement_classes, if: proc { self.billing_type == "replacement" }
  before_update :decrease_member_replacement_classes,
                if: proc { self.billing_type == "replacement" && self.quantity_changed? }
  before_update :increment_member_replacement_classes,
                if: proc { self.billing_type == "replacement" && (self.status_changed? && self.cancelled?) }
  after_save :set_workout_status
  after_save :free_members_workouts, if: proc { self.cancelled? }
  before_destroy :increment_member_replacement_classes, if: proc { self.billing_type == "replacement" }
  before_destroy :set_workout_status_to_nil

  def value_cents
    (price_cents || 0) * (quantity || 0)
  end

  def decrease_member_replacement_classes
    replacement_difference = -self.quantity ## Item Created
    replacement_difference += self.quantity_was if self.quantity_changed? ## Item quantity changed
    member = self.member
    member.replacement_classes += replacement_difference
    member.save!
  end

  def increment_member_replacement_classes
    replacement_difference = self.quantity ## Item Destroyed or canceled
    member = self.member
    member.replacement_classes += replacement_difference
    member.save!
  end

  def populate_member_and_payer
    self.member = self.invoice.member
    self.payer = self.invoice.member
  end

  def set_workout_status
    status = self.status
    self.members_workouts.each do |workout|
      workout.status = status
      workout.save!
    end
  end

  def set_workout_status_to_nil
    self.members_workouts.each do |workout|
      workout.status = nil
      workout.save!
    end
  end

  def free_members_workouts
    self.members_workouts.each do |workout|
      workout.billing_item = nil
      workout.save!
    end
  end
end
