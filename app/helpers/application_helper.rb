module ApplicationHelper
  def flash_class(level)
    case level.to_sym
    when :notice
      "alert alert-primary"
    when :success
      "alert alert-success"
    when :error
      "alert alert-danger"
    when :alert
      "alert alert-danger"
    end
  end
end
