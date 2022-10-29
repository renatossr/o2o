class Workout < ApplicationRecord
  has_and_belongs_to_many :members
  belongs_to :coach, optional: true
  belongs_to :calendar_event, optional: true

  accepts_nested_attributes_for :members

  scope :all_processed, -> { where(status: %w[cancelled confirmed]) }
end
