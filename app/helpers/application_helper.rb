module ApplicationHelper

  def admin?
    current_user&.admin?
  end

  def teacher?
    current_user&.teacher?
  end

end
