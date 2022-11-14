class CoachesController < ApplicationController
  before_action :set_coach, only: %i[show edit update destroy]
  before_action :sanitize_values, only: %i[create update]

  # GET /coaches or /coaches.json
  def index
    @q = Coach.ransack(params[:q])
    @coaches = @q.result(distinct: true)
    @coaches = @coaches.page(params[:page])
  end

  # GET /coaches/1 or /coaches/1.json
  def show
  end

  # GET /coaches/new
  def new
    @coach = Coach.new
  end

  # GET /coaches/1/edit
  def edit
  end

  # POST /coaches or /coaches.json
  def create
    @coach = Coach.new(coach_params)

    if @coach.save
      redirect_to coaches_url, notice: "Coach was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /coaches/1 or /coaches/1.json
  def update
    if @coach.update(coach_params)
      redirect_to coaches_url, notice: "Coach was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /coaches/1 or /coaches/1.json
  def destroy
    @coach.destroy
    redirect_to coaches_url, notice: "Coach was successfully destroyed."
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_coach
    @coach = Coach.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def coach_params
    params.require(:coach).permit(:first_name, :last_name, :alias, :cel_number, :pay_fixed, :pay_per_workout)
  end

  def sanitize_values
    params[:coach][:cel_number] = params[:coach][:cel_number].sub("(", "").sub(")", "").sub("-", "").sub(" ", "")
    params[:coach][:pay_fixed] = (params[:coach][:pay_fixed].sub(".", "").sub(",", ".").to_d * 100).to_i
    params[:coach][:pay_per_workout] = (params[:coach][:pay_per_workout].sub(".", "").sub(",", ".").to_d * 100).to_i
  end
end
