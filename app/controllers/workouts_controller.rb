class WorkoutsController < ApplicationController
  before_action :set_workout, only: %i[show edit update destroy]

  # GET /workouts or /workouts.json
  def index
    @workouts = Workout.all
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

    respond_to do |format|
      if @workout.save
        format.html do
          redirect_to workout_url(@workout),
                      notice: "Workout was successfully created."
        end
        format.json { render :show, status: :created, location: @workout }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json do
          render json: @workout.errors, status: :unprocessable_entity
        end
      end
    end
  end

  # PATCH/PUT /workouts/1 or /workouts/1.json
  def update
    respond_to do |format|
      if @workout.update(workout_params)
        format.html do
          redirect_to workout_url(@workout),
                      notice: "Workout was successfully updated."
        end
        format.json { render :show, status: :ok, location: @workout }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json do
          render json: @workout.errors, status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /workouts/1 or /workouts/1.json
  def destroy
    @workout.destroy

    respond_to do |format|
      format.html do
        redirect_to workouts_url, notice: "Workout was successfully destroyed."
      end
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_workout
    @workout = Workout.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def workout_params
    params.require(:workout).permit(
      :member_id,
      :coach_id,
      :start_at,
      :end_at,
      :location,
      :comments,
    )
  end
end
