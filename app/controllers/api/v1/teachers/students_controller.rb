class Api::V1::Teachers::StudentsController < ApiController
  before_action :require_admin_or_self!
  before_action :set_teacher

  def index
    students = @teacher.students

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

  def create
    student = @teacher.students.build(student_params)

    if student.save
      render json: {
        message: "Student created successfully under teacher #{@teacher.name}",
        student: {
          id: student.id,
          name: student.name,
          email: student.email,
          age: student.age,
          course: student.course,
          city: student.city,
          marks: student.marks,
          result: student.result,
          teacher: {
            id: @teacher.id,
            name: @teacher.name,
            email: @teacher.email
          }
        }
      }, status: :created
    else
      render json: { errors: student.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_teacher
    @teacher = User.teacher.find_by(id: params[:teacher_id])

    if @teacher.nil?
      render json: { errors: [ "Teacher not found" ] }, status: :not_found
    end
  end

  def student_params
    params.require(:student).permit(:name, :email, :age, :course, :city, :marks)
  end

  def require_admin_or_self!
    return if current_api_user.admin?

    teacher_id = Integer(params[:teacher_id])

    return if current_api_user.id == teacher_id

    render json: {
      errors: [
        "Access denied. You can only view your own students."
      ]
    }, status: :forbidden

  rescue ArgumentError, TypeError
    render json: {
      errors: [ "Invalid teacher id." ]
    }, status: :bad_request
  end
end
