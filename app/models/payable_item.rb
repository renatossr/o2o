class PayableItem < ApplicationRecord
  has_many :workouts
  belongs_to :payable
  belongs_to :coach

  before_validation :populate_coach, if: proc { self.payable.present? }
  before_save :calculate_value_cents

  def value_cents
    (price_cents || 0) * (quantity || 0)
  end

  def calculate_value_cents
    self.value_cents = self.price_cents * self.quantity
  end

  def populate_coach
    self.coach = self.payable.coach
  end
end
