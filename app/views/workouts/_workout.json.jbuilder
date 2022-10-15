json.extract! workout, :id, :member_id, :coach_id, :start_at, :end_at, :location, :comments, :created_at, :updated_at
json.url workout_url(workout, format: :json)
