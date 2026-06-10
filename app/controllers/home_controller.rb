class HomeController < ApplicationController
  def index
    @total_students = Student.count

    @java_students = Student.where(course: "Java").count

    @react_students = Student.where(course: "React").count

    @ruby_students = Student.where(course: "Ruby").count

    @rails_students = Student.where(course: "Rails").count

    @recent_students = Student.order(created_at: :desc).limit(5)
  end
end
