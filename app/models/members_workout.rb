class MembersWorkout < ApplicationRecord
  belongs_to :member
  belongs_to :workout
end
