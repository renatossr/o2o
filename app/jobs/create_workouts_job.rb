class CreateWorkoutsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later

    start_at, end_at = args
    start_time = args[:start_at]
    end_time = args[:end_at]

    puts start_time
  end
end
