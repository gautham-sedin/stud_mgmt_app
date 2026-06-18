class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  private

  def require_admin!
    return if current_user.admin?
    redirect_to root_path, alert: "Access denied."
  end

  def require_teacher!
    return if current_user.teacher?
    redirect_to root_path, alert: "Access denied."
  end
end
