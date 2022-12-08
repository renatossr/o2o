class WorkoutsController < ApplicationController
  before_action :set_workout, only: %i[show edit update destroy invoice_individual_workout]

  # GET /workouts or /workouts.json
  def index
    authorize Workout
    @workouts = Workout.reviewed.order("start_at desc").page(params[:page])
  end

  # GET /workouts/1 or /workouts/1.json
  def show
    authorize @workout
  end

  # GET /workouts/new
  def new
    @workout = Workout.new
    authorize @workout
  end

  # GET /workouts/1/edit
  def edit
    authorize @workout
  end

  # POST /workouts or /workouts.json
  def create
    @workout = Workout.new(workout_params)
    authorize @workout
    @workout.reviewed = true
    if @workout.save
      flash[:success] = "Treino criado com sucesso."
      redirect_to workouts_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /workouts/1 or /workouts/1.json
  def update
    authorize @workout
    if @workout.update(workout_params)
      flash[:success] = "Treino alterado com sucesso."
      redirect_to workout_url(@workout)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /workouts/1 or /workouts/1.json
  def destroy
    authorize @workout
    @workout.destroy
    flash[:success] = "Treino removido com sucesso."
    redirect_to workouts_url
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_workout
    @workout = Workout.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def workout_params
    params.require(:workout).permit(:coach_id, :with_replacement, :cancelled, :gympass, :start_at, :end_at, :location, :comments, member_ids: [])
  end
end
