module ApplicationHelper
  def admin?
    current_user&.admin?
  end

  def teacher?
    current_user&.teacher?
  end

  def flash_bootstrap_class(type)
    case type
    when "notice"
      "success"
    when "alert"
      "danger"
    else
      "info"
    end
  end
end
