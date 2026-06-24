class Student < ApplicationRecord
  COURSES = %w[Ruby Rails React Java].freeze

  belongs_to :user

  belongs_to :student_user, class_name: "User", optional: true

  after_create :create_student_user_account
  after_update :sync_student_user_account
  after_destroy :destroy_student_user_account

  scope :search, ->(term) {
    search_term = "%#{sanitize_sql_like(term)}%"
    where("name LIKE :search OR email LIKE :search", search: search_term)
  }

  scope :by_course, ->(course_name) {
    where(course: course_name)
  }

  scope :by_grade, ->(grade) {
    case grade.upcase
    when "A" then where(marks: 80..100)
    when "B" then where(marks: 70..79)
    when "C" then where(marks: 60..69)
    when "D" then where(marks: 50..59)
    when "E" then where(marks: 35..49)
    when "F" then where(marks: 0..34)
    else none
    end
  }

  validates :name, presence: true

  validates :email,
    presence: true,
    uniqueness: true,
    format: {
      with: URI::MailTo::EMAIL_REGEXP
    }

  validates :age,
    presence: true,
    numericality: {
      greater_than: 0
    }

  validates :course,
    presence: true,
    inclusion: { in: COURSES }

  validates :city,
    presence: true

  validates :marks,
    numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 100
    },
    allow_nil: true

  def result
    return "NA" if marks.nil?

    marks >= 35 ? "Pass" : "Fail"
  end

  private

  def create_student_user_account
    return if User.exists?(email: email)

    User.create!(
      name: name,
      email: email,
      password: "password123",
      password_confirmation: "password123",
      role: :student
    )
  end

  def sync_student_user_account
    if saved_change_to_email? || saved_change_to_name?
      old_email = saved_change_to_email ? email_before_last_save : email
      user = User.find_by(email: old_email)

      if user&.student?
        user.update(
          email: email,
          name: name
        )
      end
    end
  end

  def destroy_student_user_account
    user = User.find_by(email: email)
    user.destroy if user&.student?
  end
end
