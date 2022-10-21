class MembersController < ApplicationController
  before_action :set_member, only: %i[show edit update destroy]
  before_action :sanitize_values, only: %i[create update]

  # GET /members or /members.json
  def index
    @members = Member.all
  end

  # GET /members/1 or /members/1.json
  def show
  end

  # GET /members/new
  def new
    @member = Member.new
  end

  # GET /members/1/edit
  def edit
  end

  # POST /members or /members.json
  def create
    @member = Member.new(member_params)

    respond_to do |format|
      if @member.save
        format.html do
          redirect_to members_url, notice: "Member was successfully created."
        end
        format.json { render :show, status: :created, location: @member }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json do
          render json: @member.errors, status: :unprocessable_entity
        end
      end
    end
  end

  # PATCH/PUT /members/1 or /members/1.json
  def update
    respond_to do |format|
      if @member.update(member_params)
        format.html do
          redirect_to members_url, notice: "Member was successfully updated."
        end
        format.json { render :show, status: :ok, location: @member }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json do
          render json: @member.errors, status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /members/1 or /members/1.json
  def destroy
    @member.destroy

    respond_to do |format|
      format.html do
        redirect_to members_url, notice: "Member was successfully destroyed."
      end
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_member
    @member = Member.find(params[:id])
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
      :active,
    )
  end

  def sanitize_values
    params[:member][:cel_number] = params[:member][:cel_number]
      .sub("(", "")
      .sub(")", "")
      .sub("-", "")
      .sub(" ", "")
    params[:member][:subscription_price] = (
      params[:member][:subscription_price].sub(".", "").sub(",", ".").to_d * 100
    ).to_i
    params[:member][:class_price] = (
      params[:member][:class_price].sub(".", "").sub(",", ".").to_d * 100
    ).to_i
  end
end
