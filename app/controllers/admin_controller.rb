class AdminController < ApplicationController
  def settings
    authorize GCalendar, policy_class: AdminPolicy
  end

  def user_management
    authorize User, policy_class: AdminPolicy
    @users = User.all.page(params[:page])
  end
end
