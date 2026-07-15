class Api::V1::StudentsController < ApiController
  before_action :require_teacher_or_admin!
  before_action :set_student, only: [ :show, :update, :destroy ]

  def index
    students = if current_api_user.admin?
      Student.all
    else
      current_api_user.students
    end

    if params[:name].present?
      students = students.search(params[:name])
    end

    if params[:course].present?
      students = students.by_course(params[:course])
    end

    render json: students.map { |student|
      {
        id: student.id,
        name: student.name,
        email: student.email,
        age: student.age,
        course: student.course,
        city: student.city,
        marks: student.marks,
        result: student.result
      }
    }, status: :ok
  end

  def show
    render json: {
      id: @student.id,
      name: @student.name,
      email: @student.email,
      age: @student.age,
      course: @student.course,
      city: @student.city,
      marks: @student.marks,
      result: @student.result,
      teacher: {
        id: @student.user.id,
        name: @student.user.name,
        email: @student.user.email
      }
    }, status: :ok
  end

  def create
    student = if current_api_user.admin?
      Student.new(student_params)
    else
      current_api_user.students.build(student_params)
    end

    if student.save
      render json: {
        message: "Student created successfully",
        student: {
          id: student.id,
          name: student.name,
          email: student.email,
          age: student.age,
          course: student.course,
          city: student.city,
          marks: student.marks,
          result: student.result
        }
      }, status: :created
    else
      render json: { errors: student.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @student.update(student_params)
      render json: {
        message: "Student updated successfully",
        student: {
          id: @student.id,
          name: @student.name,
          email: @student.email,
          age: @student.age,
          course: @student.course,
          city: @student.city,
          marks: @student.marks,
          result: @student.result
        }
      }, status: :ok
    else
      render json: { errors: @student.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @student.destroy
    render json: { message: "Student deleted successfully" }, status: :ok
  end

  private

  def set_student
    students = if current_api_user.admin?
      Student.all
    elsif current_api_user.teacher?
      current_api_user.students
    else
      Student.where(email: current_api_user.email)
    end

    @student = students.find_by(id: params[:id])

    if @student.nil?
      render json: { errors: [ "Student not found" ] }, status: :not_found
    end
  end

  def student_params
    permitted = [ :name, :email, :age, :course, :city, :marks ]
    permitted << :user_id if current_api_user.admin?
    params.require(:student).permit(permitted)
  end

  def require_teacher_or_admin!
    unless current_api_user.admin? || current_api_user.teacher?
      render json: { errors: [ "Access denied. Teachers and Admins only." ] }, status: :forbidden
    end
  end
end
