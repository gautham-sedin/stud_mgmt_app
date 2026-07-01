# test/controllers/students_controller_test.rb
require "test_helper"

class StudentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @student_record = students(:one)
    # Automatically created student user matched by email
    @student_user = User.create!(
      name: @student_record.name,
      email: @student_record.email,
      password: "password123",
      role: :student
    )
  end

  test "student user should load root dashboard successfully" do
    sign_in @student_user
    get root_url
    assert_response :success
  end

  test "student user should not get index list of students" do
    sign_in @student_user
    get students_url
    assert_redirected_to root_url
    follow_redirect!
    assert_match "Access denied", response.body
  end

  test "student user should get their own show page" do
    sign_in @student_user
    get student_url(@student_record)
    assert_response :success
  end

  test "student user should not view another student's profile page" do
    sign_in @student_user
    other_student = students(:two)
    get student_url(other_student)
    assert_redirected_to root_url
    follow_redirect!
    assert_match "Access denied", response.body
  end
end
