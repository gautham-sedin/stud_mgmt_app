class StudentsController < ApplicationController
  before_action :require_teacher_or_admin!, except: [ :show ]
  before_action :set_student, only: [
    :show,
    :edit,
    :update,
    :destroy,
    :remove_profile_photo,
    :remove_document,
    :download_report
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
    @student =
      if current_user.admin?
        Student.new(student_params)
      else
        current_user.students.build(student_params)
      end

    if @student.save
      redirect_to @student, notice: "Student created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    attachments_uploaded = attachments_uploaded?

    if @student.update(student_params)
      if attachments_uploaded
        StudentNotificationService.send_attachment_upload_notifications(@student)
      end

      redirect_to @student, notice: "Student updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @student.destroy

    redirect_to students_path, notice: "Student deleted successfully."
  end

  def remove_profile_photo
    @student.profile_photo.purge

    redirect_to @student, notice: "Profile photo deleted successfully."
  end

  def remove_document
    attachment = @student.documents.attachments.find_by(id: params[:attachment_id])

    redirect_to @student, alert: "Document not found." and return unless attachment

    attachment.purge

    redirect_to @student, notice: "Document deleted successfully."
  end

  def download_report
    Rails.logger.info @student.inspect
    pdf = StudentReportPdfService.new(@student).generate

    send_data pdf,
              filename: "#{@student.name.parameterize}_report.pdf",
              type: "application/pdf",
              disposition: "attachment"

    unless student.report_card.attached?
      redirect_back(
        fallback_location: root_path,
        alert: "Report card has not been generated yet."
      )
      return
    end

    redirect_to rails_blob_path(
      student.report_card,
      disposition: "attachment"
    )
  end

  def generate_report
    if current_user.student?
      student = Student.find_by!(email: current_user.email)
    else
      student = @student
    end

    StudentReportService.queue(student)

    redirect_back(
      fallback_location: root_path,
      notice: "Report generation has been queued successfully."
    )
  end

  def generate_all_reports
    StudentReportService.queue_all

    redirect_to students_path,
                notice: "Report generation has been queued successfully."
  end

  # Private methods
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
      :marks,
      :profile_photo,
      documents: []
    ]

    permitted_attributes << :user_id if current_user.admin?

    params.require(:student).permit(permitted_attributes)
  end

  def attachments_uploaded?
    params[:student][:profile_photo].present? || params[:student][:documents].present?
  end
end
