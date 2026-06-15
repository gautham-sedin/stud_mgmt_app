class Student < ApplicationRecord
  validates :name, presence: true

  validates :email,
    presence: true,
    uniqueness: true,
    format: {
      with: URI::MailTo::EMAIL_REGEXP,
    }

  validates :age,
    presence: true,
    numericality: {
      greater_than: 0
    }

  validates :course,
    presence: true

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
