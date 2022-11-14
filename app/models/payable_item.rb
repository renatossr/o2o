class PayableItem < ApplicationRecord
  has_many :workouts
  belongs_to :payable
  belongs_to :coach

  before_save :calculate_value_cents

  def calculate_value_cents
    self.value_cents = self.price_cents * self.quantity
  end
end
