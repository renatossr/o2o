class Coach < ApplicationRecord
  has_many :workouts
  has_many :payables
  has_many :payable_items

  validates :first_name, presence: true
  validates :last_name, presence: true

  def name
    "#{first_name} #{last_name}"
  end

  def payable?
    has_fixed_salary? || has_individual?
  end

  def has_fixed_salary?
    pay_fixed.present? && pay_fixed > 0
  end

  def has_individual?
    pay_per_workout.present? && pay_per_workout > 0
  end

  def is_already_in_billing_cycle?(range)
    result = false
    payable_items.each do |item|
      if item.payable.present? && range.cover?(item.payable.reference_date)
        result = true
        break
      end
    end
    result
  end

  ransacker :name, formatter: proc { |v| v.mb_chars.downcase.to_s } do |parent|
    Arel::Nodes::NamedFunction.new("LOWER", [Arel::Nodes::NamedFunction.new("concat_ws", [Arel::Nodes::SqlLiteral.new("' '"), parent.table[:first_name], parent.table[:last_name]])])
  end
end
