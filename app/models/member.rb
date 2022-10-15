class Member < ApplicationRecord
    has_many :workouts
    has_many :invoices
    has_many :items
    has_many :coaches, -> { distinct }, through: :workouts

    def name
        "#{first_name} #{last_name}"
    end
end
