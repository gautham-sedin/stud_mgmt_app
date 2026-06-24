class Api::V1::AuthController < ApiController
  skip_before_action :authenticate_api_user!

  def login
    user = User.find_by(email: params[:email])

    if user&.valid_password?(params[:password])
      token = generate_token(user)
      render json: {
        message: "Login successful",
        token: token,
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role
        }
      }, status: :ok
    else
      render json: { errors: ["Invalid email or password"] }, status: :unauthorized
    end
  end

  private

  def generate_token(user)
    payload = {
      user_id: user.id,
      email: user.email,
      role: user.role,
      exp: 24.hours.from_now.to_i
    }
    JWT.encode(payload, jwt_secret, "HS256")
  end
end