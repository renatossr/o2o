class CalendarEventController < ApplicationController
  before_action :set_entities, only: %i[process_events confirm update destroy]

  def index
    authorize CalendarEvent
    final_date = DateTime.current.end_of_day
    start_date = final_date.beginning_of_month - 1.month
    @events = CalendarEvent.where(end_at: (start_date..final_date)).page(params[:page])
  end

  def process_events
    authorize CalendarEvent
    @coaches = Coach.all
    @members = Member.all
    @unconfirmed_total_count = @events.count
    @events = @events.page(params[:page])
  end

  # PATCH/PUT /proc_event/1
  def update
    authorize @current_event
    @current_event.reviewed = true
    @current_event.alerts = []
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
    final_date = DateTime.current.end_of_day
    start_date = final_date.beginning_of_month - 1.month
    @events = CalendarEvent.includes(workout: :members_workouts).where(start_at: (start_date..final_date)).unreviewed.order("start_at desc")
    @current_event = CalendarEvent.find(params[:id]) unless params[:id].blank?
  end

  # Only allow a list of trusted parameters through.
  def event_params
    params.require(:calendar_event).permit(workout_attributes: [:id, :with_replacement, :gympass, :cancelled, :coach_id, member_ids: []])
  end
end
