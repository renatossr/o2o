class GCalendarPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end

  def index
    true
  end

  def redirect
    true
  end

  def callback
    true
  end

  def events
    true
  end

  def eventsFullSync?
    true
  end
end
