class Api::V1::TeachersController < ApiController
  before_action :require_admin!
  before_action :set_teacher, only: [ :show, :update, :destroy ]

  def index
    teachers = User.teacher
    if params[:course].present?
      teachers = teachers.joins(:students).where(students: { course: params[:course] }).distinct
    end
    render json: teachers.map { |teacher|
      {
        id: teacher.id,
        name: teacher.name,
        email: teacher.email,
        role: teacher.role,
        total_students: teacher.students.count
      }
    }, status: :ok
  end

  def show
    render json: {
      id: @teacher.id,
      name: @teacher.name,
      email: @teacher.email,
      role: @teacher.role,
      students: @teacher.students.map { |student|
        {
          id: student.id,
          name: student.name,
          email: student.email,
          course: student.course
        }
      }
    }, status: :ok
  end

  def create
    teacher = User.new(teacher_params)
    teacher.role = :teacher

    if teacher.save
      render json: {
        message: "Teacher created successfully",
        teacher: {
          id: teacher.id,
          name: teacher.name,
          email: teacher.email,
          role: teacher.role
        }
      }, status: :created
    else
      render json: { errors: teacher.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @teacher.update(teacher_params)
      render json: {
        message: "Teacher updated successfully",
        teacher: {
          id: @teacher.id,
          name: @teacher.name,
          email: @teacher.email,
          role: @teacher.role
        }
      }, status: :ok
    else
      render json: { errors: @teacher.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @teacher.destroy
    render json: { message: "Teacher deleted successfully" }, status: :ok
  end

  private

  def set_teacher
    @teacher = User.teacher.find_by(id: params[:id])

    if @teacher.nil?
      render json: { errors: [ "Teacher not found" ] }, status: :not_found
    end
  end

  def teacher_params
    params.require(:teacher).permit(:name, :email, :password, :password_confirmation)
  end

  def require_admin!
    unless current_api_user.admin?
      render json: { errors: [ "Access denied. Admins only." ] }, status: :forbidden
    end
  end
end
