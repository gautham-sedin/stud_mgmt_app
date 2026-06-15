class HomeController < ApplicationController
  def index
    @total_students = Student.count

    @course_counts = Student.group(:course).count

    @recent_students = Student.order(created_at: :desc).limit(5)
  end
end
