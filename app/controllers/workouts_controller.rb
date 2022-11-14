class WorkoutsController < ApplicationController
  before_action :set_workout, only: %i[show edit update destroy invoice_individual_workout]

  # GET /workouts or /workouts.json
  def index
    @workouts = Workout.all.order("start_at desc").page(params[:page])
  end

  # GET /workouts/1 or /workouts/1.json
  def show
  end

  # GET /workouts/new
  def new
    @workout = Workout.new
  end

  # GET /workouts/1/edit
  def edit
  end

  # POST /workouts or /workouts.json
  def create
    @workout = Workout.new(workout_params)
    @workout.reviewed = true
    if @workout.save
      redirect_to workouts_path, notice: "Workout was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /workouts/1 or /workouts/1.json
  def update
    if @workout.update(workout_params)
      redirect_to workout_url(@workout), notice: "Workout was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /workouts/1 or /workouts/1.json
  def destroy
    @workout.destroy
    redirect_to workouts_url, notice: "Workout was successfully destroyed."
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_workout
    @workout = Workout.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def workout_params
    params.require(:workout).permit(:coach_id, :start_at, :end_at, :location, :comments, member_ids: [])
  end
end
