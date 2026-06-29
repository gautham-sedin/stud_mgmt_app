class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise  :database_authenticatable,
          :registerable,
          :recoverable,
          :rememberable,
          :validatable

  enum :role, {
    admin: 0,
    teacher: 1,
    student: 2
  }

  has_many :students, dependent: :destroy

  has_one :student_profile,
          class_name: "Student",
          foreign_key: :email,
          primary_key: :email,
          dependent: :destroy

  validates :name, presence: true
end
