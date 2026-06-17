require "test_helper"

class StudentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @student = students(:one)
    # Sign in as admin to keep all tests simple and authorized
    sign_in users(:admin)
  end

  test "should get index" do
    get students_url
    assert_response :success
  end

  test "should get new" do
    get new_student_url
    assert_response :success
  end

  test "should create student" do
    assert_difference("Student.count") do
      post students_url, params: {
        student: { age: 20, city: "Chennai", course: "Rails", email: "new@example.com", name: "New" }
      }
    end
    assert_redirected_to student_url(Student.last)
  end

  test "should show student" do
    get student_url(@student)
    assert_response :success
  end

  test "should get edit" do
    get edit_student_url(@student)
    assert_response :success
  end

  test "should update student" do
    patch student_url(@student), params: { student: { city: "Updated City" } }
    assert_redirected_to student_url(@student)
  end

  test "should destroy student" do
    assert_difference("Student.count", -1) do
      delete student_url(@student)
    end
    assert_redirected_to students_url
  end
end
