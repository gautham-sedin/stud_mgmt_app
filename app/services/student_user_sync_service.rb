class StudentUserSyncService
  def initialize(student)
    @student = student
  end

  def create_user
    return if User.exists?(email: @student.email)

    User.create!(
      name: @student.name,
      email: @student.email,
      password: "password123",
      password_confirmation: "password123",
      role: :student
    )
  end

  def update_user
    return unless @student.saved_change_to_email? || @student.saved_change_to_name?

    old_email =
      if @student.saved_change_to_email?
        @student.email_before_last_save
      else
        @student.email
      end

    user = User.find_by(email: old_email)

    return unless user&.student?

    user.update!(
      name: @student.name,
      email: @student.email
    )
  end

  def destroy_user
    user = User.find_by(email: @student.email)

    user.destroy if user&.student?
  end
end
