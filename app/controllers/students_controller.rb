class StudentsController < ApplicationController
  before_action :set_student, only: [
    :show,
    :edit,
    :update,
    :destroy
  ]

  def index
    @students = Student.all

    if(params[:search].present?)
      @students = @students.where(
        "name LIKE ? OR email LIKE ?",
        "%#{params[:search]}%",
        "%#{params[:search]}%"
      )
    end

    if params[:course].present?
      @students = @students.where(course: params[:course])
    end

    @students = @students.order(created_at: :desc)
  end

  def show
  end

  def new
    @student = Student.new
  end

  def create
    @student = Student.new(student_params)

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

  def set_student
    @student = Student.find(params[:id])
  end

  def student_params
    params.require(:student).permit(
      :name,
      :email,
      :age,
      :course,
      :city,
      :marks
    )
  end
end
