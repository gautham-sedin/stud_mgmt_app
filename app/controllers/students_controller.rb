  class StudentsController < ApplicationController
    before_action :require_teacher_or_admin!, except: [ :show ]
    before_action :set_student, only: [
      :show,
      :edit,
      :update,
      :destroy
    ]

    def index
      @students =
        if current_user.admin?
          Student.all
        else
          current_user.students
        end

      if params[:search].present?
        @students = @students.search(params[:search])
      end

      if params[:course].present?
        @students = @students.by_course(params[:course])
      end

      @students = @students.order(created_at: :desc)
    end

    def show
      if current_user.student?
        student_profile = Student.find_by(email: current_user.email)
        if student_profile.nil? || student_profile.id != @student.id
          redirect_to root_path, alert: "Access denied. You can only view your own student profile."
        end
      end
    end

    def new
      @student = Student.new
    end

    def create
      @student = current_user.students.build(student_params)

      if @student.save
        redirect_to @student, notice: "Student created successfully."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @student.update(student_params)
        redirect_to @student, notice: "Student updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @student.destroy

      redirect_to students_path, notice: "Student deleted successfully."
    end

    private

    def set_student
      scope = (current_user.admin? || current_user.student?) ? Student.all : current_user.students
      @student = scope.find(params[:id])
    end

    def student_params
      permitted_attributes = [
        :name,
        :email,
        :age,
        :course,
        :city,
        :marks
      ]

      permitted_attributes << :user_id if current_user.admin?

      params.require(:student).permit(permitted_attributes)
    end
  end
