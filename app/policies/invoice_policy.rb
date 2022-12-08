class InvoicePolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end

  def index?
    user.present?
  end

  def ready_to_send?
    user&.admin?
  end

  def new?
    user.present?
  end

  def new_from_workout?
    user.present?
  end

  def create?
    user.present?
  end

  def show?
    user.present?
  end

  def edit?
    user.present?
  end

  def update?
    user.present?
  end

  def destroy?
    user&.admin?
  end

  def cancel?
    user&.admin?
  end

  def cancel_and_mirror?
    user&.admin?
  end

  def confirm_all?
    user&.admin?
  end

  def confirm?
    user.present?
  end
end
