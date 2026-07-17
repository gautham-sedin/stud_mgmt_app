module AppConstants
    STUDENT_DEFAULT_PASSWORD =
      Rails.application.credentials.dig(:student, :default_password)
end
