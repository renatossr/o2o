class Users::InvitationsController < Devise::InvitationsController
  before_action :configure_permitted_parameters

  def after_invite_path_for(resource)
    user_management_path
  end

  protected

  # Permit the new params here.
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:invite, keys: %i[first_name last_name role])
  end
end
