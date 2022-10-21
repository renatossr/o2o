class Workout < ApplicationRecord
  has_and_belongs_to_many :members
  belongs_to :coach
  belongs_to :event, optional: true

  accepts_nested_attributes_for :members
end
