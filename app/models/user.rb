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
    teacher: 1
  }

  has_many :students, dependent: :destroy

  validates :name, presence: true
end
