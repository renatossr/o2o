class Users::InvitationsController < Devise::InvitationsController
  before_action :configure_permitted_parameters

  protected

  # Permit the new params here.
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:invite, keys: %i[first_name last_name role])
  end
end
