class MembersController < ApplicationController
  before_action :set_member, only: %i[show edit update destroy]
  before_action :sanitize_values, only: %i[create update]

  # GET /members or /members.json
  def index
    authorize Member
    search_param = params[:q]
    search_terms = search_param[:first_name_or_last_name_or_alias_or_cel_number_cont_any] if search_param.present?
    if search_terms.present?
      search_terms = search_terms.split(" ") unless search_terms.kind_of?(Array)
      search_param[:first_name_or_last_name_or_alias_or_cel_number_cont_any] = search_terms
    end
    @q = Member.ransack(search_param)
    @members = @q.result
    @members = @members.page(params[:page])
  end

  # GET /members/1
  def show
    authorize @member
  end

  # GET /members/new
  def new
    @member = Member.new
    authorize @member
  end

  # GET /members/1/edit
  def edit
    authorize @member
  end

  # POST /members
  def create
    @member = Member.new(member_params)
    authorize @member

    if @member.save
      flash[:success] = "Aluno criado com sucesso."
      if params[:previous_request]
        redirect_to params[:previous_request]
      else
        redirect_to members_url
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /members/1
  def update
    authorize @member
    if @member.update(member_params)
      flash[:success] = "Dados do aluno alterados com sucesso."
      redirect_to members_url
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /members/1
  def destroy
    authorize @member
    @member.destroy
    flash[:success] = "Aluno removido com sucesso."
    redirect_to members_url
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_member
    @member = Member.find(params[:id])
    @members_workouts = @member.members_workouts.joins(:workout).order("start_at DESC")
  end

  # Only allow a list of trusted parameters through.
  def member_params
    params.require(:member).permit(
      :first_name,
      :last_name,
      :alias,
      :cel_number,
      :responsible_id,
      :subscription_price,
      :subscription_type,
      :class_price,
      :double_class_price,
      :triple_class_price,
      :loyal,
      :active,
      :replacement_classes,
      :monday,
      :tuesday,
      :wednesday,
      :thursday,
      :friday,
      :saturday,
      :sunday,
    )
  end

  def sanitize_values
    params[:member][:cel_number] = params[:member][:cel_number].sub("(", "").sub(")", "").sub("-", "").sub(" ", "")
    params[:member][:subscription_price] = (params[:member][:subscription_price].sub(".", "").sub(",", ".").to_d * 100).to_i
    params[:member][:subscription_type] = params[:member][:subscription_type].to_i if params[:member][:subscription_type].present?
    params[:member][:class_price] = (params[:member][:class_price].sub(".", "").sub(",", ".").to_d * 100).to_i
    params[:member][:double_class_price] = (params[:member][:double_class_price].sub(".", "").sub(",", ".").to_d * 100).to_i
    params[:member][:triple_class_price] = (params[:member][:triple_class_price].sub(".", "").sub(",", ".").to_d * 100).to_i
  end
end
