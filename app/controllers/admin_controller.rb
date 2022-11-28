class AdminController < ApplicationController
  before_action :set_user, only: %i[destroy_user edit_user update_user]

  def settings
    authorize GCalendar, policy_class: AdminPolicy
  end

  def user_management
    authorize User, policy_class: AdminPolicy
    @users = User.all.page(params[:page])
  end

  def edit_user
    authorize @user, policy_class: AdminPolicy
  end

  def update_user
    authorize @user, policy_class: AdminPolicy
    if @user.update(user_params)
      flash[:success] = "Dados do usuário alterados com sucesso."
      redirect_to user_management_path
    else
      render :edit_user, status: :unprocessable_entity
    end
  end

  def destroy_user
    authorize @user, policy_class: AdminPolicy
    @user.destroy
    flash[:success] = "usuário removido com sucesso."
    redirect_to user_management_path
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :role)
  end

  def set_user
    @user = User.find(params[:id])
  end
end
