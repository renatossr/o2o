require "faker"

Faker::Config.locale = "pt-BR"

Member.destroy_all
10.times do
  firstName = Faker::Name.first_name
  subscriptionPrice = Faker::Number.within(range: 1000..2000) * 100
  classPrice = Faker::Number.within(range: 100..200) * 100

  Member.create!(
    {
      first_name: firstName,
      last_name: Faker::Name.last_name,
      alias: firstName,
      cel_number: Faker::PhoneNumber.cell_phone,
      subscription_price: subscriptionPrice,
      class_price: classPrice,
    },
  )
end
p "Created #{Member.count} Members"

Coach.destroy_all
5.times do
  firstName = Faker::Name.first_name
  Coach.create!(
    {
      first_name: firstName,
      last_name: Faker::Name.last_name,
      alias: firstName,
      cel_number: Faker::PhoneNumber.cell_phone,
      pay_fixed: Faker::Number.within(range: 1000..2000) * 100,
      pay_per_workout: Faker::Number.within(range: 50..100) * 100,
    },
  )
end
p "Created #{Coach.count} Coaches"

Workout.destroy_all
CalendarEvent.destroy_all
20.times do
  title = ""
  member_ids = (Member.first.id..Member.last.id).to_a.sample(rand(1..3))
  coach_id = rand(Coach.first.id..Coach.last.id)
  time =
    Faker::Time.between(
      from: DateTime.now - 1.month,
      to: DateTime.now,
      format: :default,
    )

  member_ids.each do |id|
    if title.blank?
      title = Member.find(id).name
    else
      title += ", #{Member.find(id).name}"
    end
  end

  title += " - #{Coach.find(coach_id).name}"

  ev =
    CalendarEvent.create!(
      {
        title: title,
        start_at: time,
        end_at: Time.parse(time) + 30.minutes,
        status: "confirmada",
      },
    )

  wk =
    Workout.create!(
      {
        coach_id: coach_id,
        calendar_event_id: ev.id,
        start_at: ev.start_at,
        end_at: ev.end_at,
        location: Faker::Address.street_address,
        comments: "",
      },
    )

  member_ids.each { |id| wk.members << Member.find(id) }
end
p "Created #{Coach.count} CalendarEvents and #{Workout.count} Workouts"
