class Member < ApplicationRecord
  has_and_belongs_to_many :workouts
  has_many :invoices
  has_many :billing_items
  has_many :coaches, -> { distinct }, through: :workouts

  def name
    "#{first_name} #{last_name}"
  end

  def billable?
    has_subscription? || has_individual?
  end

  def has_subscription?
    subscription_price > 0
  end

  def has_individual?
    class_price > 0
  end

  def has_workouts_in_range?(range)
    workouts.where(start_at: range).count > 0
  end

  def responsible
    responsible_id || id
  end

  def responsible_self?
    (responsible_id == id) || (responsible_id.blank?)
  end
end
