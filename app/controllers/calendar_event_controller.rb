class CalendarEventController < ApplicationController
  def index
    @events = CalendarEvent.all
  end

  def process_events
    @events =
      CalendarEvent
        .all_unprocessed
        .where(
          start_at:
            Date.current.beginning_of_month -
              2.months..Date.current.end_of_month,
        )
        .order("start_at desc")
    if params[:event].blank?
      @current_event = @events.first
    else
      @current_event = CalendarEvent.find(params[:event])
    end
    @workout = @current_event.workout
  end
end
