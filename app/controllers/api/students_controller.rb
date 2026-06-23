class Api::StudentController < Api::BaseController
  before_action :set_student, only: [:show, :update, :destroy]

  def index
    @students = Student.all

    if params[:name].present?
      @students = @students.search(params[:name])
    end

    render json: @students.map { |s| serialize_student(s) }, status: ok
  end

  def show
    render json: serialize_student(@student), status: ok
  end

  def create
    @student = Student.new(student_params)

    if @student.save 
      render json: serialize_student(@student), status: ok
    else
      render json: { errors: @student.errors.full_messages }, status: unprocessable_entity
    end
  end

  def update
    if @student.update(student_params)
      render json: @student.serialize_student(@student), status: ok
    else
      render json: { errors: @student.errors.full_messages }. status: unprocessable_entity
    end
  end

  def destroy
    @student.destroy
    head: no_content
  end

  private

  def set_student
    @student = Student.find(params[:id])
  end

  def student_params
    params.require(:student).permit(:name, :email, :age, :course, :city, :marks, :user_id)
  end

  def serialize_student
    {
      id: student.id,
      name: student.name,
      email: student.email,
      age: student.age,
      course: student.course,
      marks: student.marks,
      teacher: student.user ? { id: student.user.id, name: student.user.name } : nil
    }
  end
end