class CalendarEventPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end

  def index?
    user.present?
  end

  def process_events?
    user.present?
  end

  def update?
    user.present?
  end
end
