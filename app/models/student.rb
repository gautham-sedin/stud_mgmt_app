class Student < ApplicationRecord
  COURSES = %w[Ruby Rails React Java].freeze

  belongs_to :user

  belongs_to :student_user, class_name: "User", optional: true

  has_one_attached :profile_photo

  has_many_attached :documents

  validate :validate_profile_photo

  validate :validate_documents

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

  private
  def validate_profile_photo
    return unless profile_photo.attached?

    Rails.logger.debug "Content Type: #{profile_photo.content_type}"
    puts "Content Type: #{profile_photo.content_type}"

    unless profile_photo.content_type.in?(%w[image/jpeg image/png])
      errors.add(:profile_photo, "must be a JPG, JPEG or PNG file")
    end

    if profile_photo.byte_size > 5.megabytes
      errors.add(:profile_photo, "size must be less than 5MB")
    end
  end

  def validate_documents
    documents.each do |document|
      unless document.content_type.in?(%w[application/pdf image/jpeg image/png])
        errors.add(:documents, "#{document.filename} has an unsupported file type. Only PDF, JPG or PNG files are allowed.")
      end

      if document.byte_size > 10.megabytes
        errors.add(:documents, "#{document.filename} size must be less than 10MBs")
      end
    end
  end
end
