module StudentsHelper
  def student?
    role == "student"
  end

  def user_account
    User.find_by(email: email)
  end
end
