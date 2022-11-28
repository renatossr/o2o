class CoachesController < ApplicationController
  before_action :set_coach, only: %i[show edit update destroy]
  before_action :sanitize_values, only: %i[create update]

  # GET /coaches or /coaches.json
  def index
    authorize Coach
    search_param = params[:q]
    search_terms = search_param[:first_name_or_last_name_or_alias_or_cel_number_cont_any] if search_param.present?
    if search_terms.present?
      search_terms = search_terms.split(" ") unless search_terms.kind_of?(Array)
      search_param[:first_name_or_last_name_or_alias_or_cel_number_cont_any] = search_terms
    end
    @q = Coach.ransack(search_param)
    @coaches = @q.result(distinct: true)
    @coaches = @coaches.page(params[:page])
  end

  # GET /coaches/1 or /coaches/1.json
  def show
    authorize @coach
  end

  # GET /coaches/new
  def new
    @coach = Coach.new
    authorize @coach
  end

  # GET /coaches/1/edit
  def edit
    authorize @coach
  end

  # POST /coaches or /coaches.json
  def create
    @coach = Coach.new(coach_params)
    authorize @coach

    if @coach.save
      flash[:success] = "Coach criado com sucesso."
      if params[:previous_request]
        redirect_to params[:previous_request]
      else
        redirect_to coaches_url
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /coaches/1 or /coaches/1.json
  def update
    authorize @coach
    if @coach.update(coach_params)
      flash[:success] = "Coach alterado com sucesso."
      redirect_to coaches_url
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /coaches/1 or /coaches/1.json
  def destroy
    authorize @coach
    @coach.destroy
    flash[:success] = "Coach removido com sucesso."
    redirect_to coaches_url
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
