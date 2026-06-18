class HomeController < ApplicationController
  def index
    if current_user.admin?
      load_admin_dashboard
    else
      load_teacher_dashboard
    end
  end

  private

  def load_teacher_dashboard
    students_scope = current_user.students

    @total_students = students_scope.count

    @course_counts =
      students_scope.group(:course).count

    @recent_students =
      students_scope
        .order(created_at: :desc)
        .limit(5)
  end

  def load_admin_dashboard
    @total_students = Student.count

    @total_teachers = User.teacher.count

    @students_per_teacher =
      User.teacher
          .includes(:students)

    @recent_students =
      Student
        .includes(:user)
        .order(created_at: :desc)
        .limit(10)
  end
end
