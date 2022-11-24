class AdminPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end

  def settings?
    user&.admin?
  end

  def user_management?
    user&.admin?
  end
end
