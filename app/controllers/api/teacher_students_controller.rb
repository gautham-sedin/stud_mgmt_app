class Api::TeacherStudentsController < Api::BaseController
  before_action :set_teacher

  # GET /api/teachers/:teacher_id/students
  def index
    @students = @teacher.students
    render json: @students.map { |s| { id: s.id, name: s.name } }, status: :ok
  end

  # POST /api/teachers/:teacher_id/students
  def create
    @student = @teacher.students.build(student_params)

    if @student.save
      render json: { id: @student.id, name: @student.name }, status: :created
    else
      render json: { errors: @student.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_teacher
    @teacher = User.teacher.find(params[:teacher_id])
  end

  def student_params
    params.require(:student).permit(:name, :email, :age, :course, :city, :marks)
  end
end