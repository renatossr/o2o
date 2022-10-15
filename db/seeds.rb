require 'faker'

Faker::Config.locale = 'pt-BR'

Member.destroy_all
10.times do
  firstName = Faker::Name.first_name
  subscriptionPrice = Faker::Number.number(digits: 4)*100
  classPrice = Faker::Number.number(digits: 3)*100

  Member.create!([{
    first_name: firstName,
    last_name: Faker::Name.last_name,
    alias: firstName,
    cel_number: Faker::PhoneNumber.cell_phone,
    subscription_price: subscriptionPrice,
    class_price: classPrice
  }])  
end
p "Created #{Member.count} Members"


Coach.destroy_all
5.times do
  firstName = Faker::Name.first_name
  Coach.create!([{
    first_name: firstName,
    last_name: Faker::Name.last_name,
    alias: firstName,
    cel_number: Faker::PhoneNumber.cell_phone,
    pay_fixed: Faker::Number.number(digits: 5),
    pay_per_workout: Faker::Number.number(digits: 5)
  }])
end
p "Created #{Coach.count} Coaches"

Workout.destroy_all
100.times do
  time = Faker::Time.between(from: DateTime.now - 1.month, to: DateTime.now, format: :default)
  Workout.create!([{
    member_id: rand(Member.first.id..Member.last.id),
    coach_id: rand(Coach.first.id..Coach.last.id),
    start_at: time,
    end_at: Time.parse(time) + 30.minutes,
    location: Faker::Address.street_address,
    comments: Faker::Lorem.sentence(word_count: 3),
  }])  
end
p "Created #{Workout.count} Workouts"