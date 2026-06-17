require "test_helper"

class StudentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @student = students(:one)
    @admin = users(:admin)
    @teacher = users(:teacher)
  end

  test "should get index as admin" do
    sign_in @admin
    get students_url
    assert_response :success
  end

  test "should get index as teacher" do
    sign_in @teacher
    get students_url
    assert_response :success
  end

  test "should redirect index when not logged in" do
    get students_url
    assert_redirected_to new_user_session_url
  end

  test "should get new when logged in" do
    sign_in @teacher
    get new_student_url
    assert_response :success
  end

  test "should create student" do
    sign_in @teacher
    assert_difference("Student.count") do
      post students_url, params: { 
        student: { 
          age: 20, 
          city: "New City", 
          course: "Rails", 
          email: "newstudent@example.com", 
          name: "New Student" 
        } 
      }
    end

    assert_redirected_to student_url(Student.last)
  end

  test "should show student" do
    sign_in @teacher
    get student_url(@student)
    assert_response :success
  end

  test "should get edit" do
    sign_in @teacher
    get edit_student_url(@student)
    assert_response :success
  end

  test "should update student" do
    sign_in @teacher
    patch student_url(@student), params: { student: { city: "Updated City" } }
    assert_redirected_to student_url(@student)
  end

  test "should destroy student" do
    sign_in @admin
    assert_difference("Student.count", -1) do
      delete student_url(@student)
    end

    assert_redirected_to students_url
  end
end
