# test/models/student_test.rb
require "test_helper"

class StudentTest < ActiveSupport::TestCase
  test "should create corresponding student user account on creation" do
    teacher = users(:teacher)

    assert_difference -> { User.student.count } => 1, -> { Student.count } => 1 do
      Student.create!(
        name: "Test Student",
        email: "teststudent@example.com",
        age: 20,
        course: "Rails",
        city: "Bangalore",
        marks: 85,
        user: teacher
      )
    end

    user = User.find_by(email: "teststudent@example.com")
    assert_not_nil user
    assert_equal "Test Student", user.name
    assert user.student?
  end
end
