class ApplicationController < ActionController::Base
  include Pundit::Authorization
  #after_action :verify_authorized #Incluir depois antes de testar a versão final
  before_action :authenticate_user!

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = "Você não tem autorização para acessar essa página."
    self.response_body = nil # This should resolve the redirect root.
    redirect_to(request.referrer || root_path)
  end
end
