class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
  end

  private

  def require_admin!
    return if current_user.admin?
    redirect_to root_path, alert: "Access denied."
  end

  def require_teacher!
    return if current_user.teacher?
    redirect_to root_path, alert: "Access denied."
  end

  def require_teacher_or_admin!
    return if current_user.admin? || current_user.teacher?
    redirect_to root_path, alert: "Access denied. Student account do not have access to this page."
  end
end
