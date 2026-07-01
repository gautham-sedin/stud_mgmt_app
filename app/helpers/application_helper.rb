module ApplicationHelper
  COURSE_BADGE_CLASSES = {
    "Ruby" => "bg-danger-subtle text-danger-emphasis",
    "Rails" => "bg-warning-subtle text-warning-emphasis",
    "Java" => "bg-info-subtle text-info-emphasis",
    "Javascript" => "bg-success-subtle bg-success-emphasis"
  }.freeze

  def course_badge_class(course)
    COURSE_BADGE_CLASSES.fetch(course, "bg-secondary-subtle text-secondary-emphasis")
  end

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
