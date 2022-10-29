class CalendarEventController < ApplicationController
  before_action :set_entities, only: %i[process_events confirm update destroy]

  def index
    @events = CalendarEvent.all.page(params[:page])
  end

  def process_events
    @unconfirmed_total_count = CalendarEvent.all_unconfirmed.count
  end

  # PATCH/PUT /proc_event/1
  def update
    @current_event.confirmed = true
    if @current_event.update(event_params)
      @current_event = @events.first
      redirect_to proc_events_url
    else
      render :process_events, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_entities
    @events = CalendarEvent.all_unconfirmed.order("start_at desc").page(params[:page])
    @current_event = CalendarEvent.find(params[:id]) unless params[:id].blank?
  end

  # Only allow a list of trusted parameters through.
  def event_params
    params.require(:calendar_event).permit(workout_attributes: [:id, :coach_id, member_ids: []])
  end
end
