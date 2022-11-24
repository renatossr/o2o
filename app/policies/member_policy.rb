class MemberPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end

  def index?
    user.present?
  end

  def show?
    user.present?
  end

  def new?
    user.present?
  end

  def edit?
    user&.admin?
  end

  def create?
    user&.present?
  end

  def update?
    user&.admin?
  end

  def destroy?
    user&.admin?
  end
end
