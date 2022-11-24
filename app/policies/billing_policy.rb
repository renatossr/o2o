class BillingPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end

  def dashboard?
    user&.admin?
  end

  def index?
    user&.admin?
  end

  def new?
    user&.admin?
  end

  def show?
    user&.admin?
  end

  def start_cycle?
    user&.admin?
  end

  def close_cycle?
    user&.admin?
  end
end
