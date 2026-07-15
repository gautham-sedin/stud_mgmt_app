class Student < ApplicationRecord
  COURSES = %w[Ruby Rails React Java].freeze

  belongs_to :user

  belongs_to :student_user, class_name: "User", optional: true

  after_create do
    StudentUserSyncService.new(self).create_user
  end

  after_update do
    StudentUserSyncService.new(self).update_user
  end

  after_destroy do
    StudentUserSyncService.new(self).destroy_user
  end

  scope :search, ->(term) {
    search_term = "%#{sanitize_sql_like(term)}%"
    where("name LIKE :search OR email LIKE :search", search: search_term)
  }

  scope :by_course, ->(course_name) {
    where(course: course_name)
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
end
