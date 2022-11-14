class MembersController < ApplicationController
  before_action :set_member, only: %i[show edit update destroy]
  before_action :sanitize_values, only: %i[create update]

  # GET /members or /members.json
  def index
    @q = Member.ransack(params[:q])
    @members = @q.result(distinct: true)
    @members = @members.page(params[:page])
  end

  # GET /members/1
  def show
  end

  # GET /members/new
  def new
    @member = Member.new
  end

  # GET /members/1/edit
  def edit
  end

  # POST /members
  def create
    @member = Member.new(member_params)

    if @member.save
      redirect_to members_url, notice: "Member was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /members/1
  def update
    if @member.update(member_params)
      redirect_to members_url, notice: "Member was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /members/1
  def destroy
    @member.destroy
    redirect_to members_url, notice: "Member was successfully destroyed."
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
      :class_price,
      :loyal,
      :active,
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
    params[:member][:subscription_price] = (
      params[:member][:subscription_price].sub(".", "").sub(",", ".").to_d * 100
    ).to_i
    params[:member][:class_price] = (params[:member][:class_price].sub(".", "").sub(",", ".").to_d * 100).to_i
  end
end
