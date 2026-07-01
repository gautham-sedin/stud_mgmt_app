class ApiController < ActionController::API
  before_action :authenticate_api_user!

  private

  def authenticate_api_user!
    header = request.headers["Authorization"]
    token = header&.split(" ")&.last

    if token.nil?
      return render json: { errors: [ "Authorization token is missing" ] }, status: :unauthorized
    end

    begin
      decoded = JWT.decode(token, jwt_secret, true, algorithm: "HS256")
      @current_api_user = User.find(decoded[0]["user_id"])
    rescue JWT::ExpiredSignature
      render json: { errors: [ "Token has expired. Please login again" ] }, status: :unauthorized
    rescue JWT::DecodeError
      render json: { errors: [ "Invalid token. Please login again" ] }, status: :unauthorized
    rescue ActiveRecord::RecordNotFound
      render json: { errors: [ "User not found" ] }, status: :unauthorized
    end
  end

  def jwt_secret
    Rails.application.secret_key_base
  end

  def current_api_user
    @current_api_user
  end
end
