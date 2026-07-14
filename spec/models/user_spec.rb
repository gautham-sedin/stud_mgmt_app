# spec/models/user_spec.rb

require "rails_helper"

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  describe "Factory" do
    it "has a valid factory" do
      expect(user).to be_valid
    end
  end

  describe "Validations" do
    it { should validate_presence_of(:name) }
  end

  describe "Associations" do
    it { should have_many(:students).dependent(:destroy) }

    it do
      should have_one(:student_profile)
        .class_name("Student")
        .with_foreign_key("email")
        .with_primary_key("email")
        .dependent(:destroy)
    end
  end

  describe "Enums" do
    it do
      should define_enum_for(:role)
        .with_values(
          admin: 0,
          teacher: 1,
          student: 2
        )
    end
  end

  describe "Role Helpers" do
    it "identifies an admin" do
      expect(build(:user, :admin)).to be_admin
    end

    it "identifies a teacher" do
      expect(build(:user, :teacher)).to be_teacher
    end

    it "identifies a student" do
      expect(build(:user, :student)).to be_student
    end
  end
end