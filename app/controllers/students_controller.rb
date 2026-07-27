class StudentsController < ApplicationController
  before_action :require_teacher_or_admin!, except: [
    :show,
    :generate_report,
    :download_report
  ]
  before_action :set_student, only: [
    :show,
    :edit,
    :update,
    :destroy,
    :remove_profile_photo,
    :remove_document,
    :download_report,
    :generate_report
  ]

  def index
    @students =
      if current_user.admin?
        Student.includes(:user)
      else
        current_user.students.includes(:user)
      end

    if params[:search].present?
      @students = @students.search(params[:search])
    end

    if params[:course].present?
      @students = @students.by_course(params[:course])
    end

    @students = @students.order(created_at: :desc)

    @pagy, @students = pagy(@students)

    if turbo_frame_request?
      render partial: "student_table"
    end
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

    respond_to do |format|
      if @student.save
        @student_count =
          if current_user.admin?
            Student.count
          else
            current_user.students.count
          end

        format.html do
          redirect_to @student, notice: "Student created successfully."
        end

        format.turbo_stream do
          if page_form?
            redirect_to @student, notice: "Student created successfully."
          else
            flash.now[:notice] = "Student created successfully."
          end
        end
      else
        format.html do
          render :new, status: :unprocessable_entity
        end

        format.turbo_stream do
          if page_form?
            render :new, formats: [ :html ], status: :unprocessable_entity
          else
            render turbo_stream: turbo_stream.replace(
              "quick_student_form",
              partial: "students/quick_form",
              locals: { student: @student }
            ), status: :unprocessable_entity
          end
        end
      end
    end
  end

  def edit
    if turbo_frame_request?
      render inline: helpers.turbo_frame_tag("student_form") {
        render_to_string(
          partial: "quick_form",
          locals: { student: @student }
        )
      }
    end
  end

  def update
    attachments_uploaded = attachments_uploaded?
    update_params = student_params

    if update_params.key?(:documents)
      new_documents = Array(update_params[:documents]).select(&:present?)
      update_params[:documents] = @student.documents.map(&:blob) + new_documents
    end

    update_params.delete(:profile_photo) unless update_params[:profile_photo].present?

    respond_to do |format|
      if @student.update(update_params)

        if attachments_uploaded
          StudentNotificationService.send_attachment_upload_notifications(@student)
        end

        format.html do
          redirect_to @student,
                      notice: "Student updated successfully."
        end

        format.turbo_stream do
          if page_form?
            redirect_to @student, notice: "Student updated successfully."
          else
            flash.now[:notice] = "Student updated successfully."
          end
        end

      else

        format.html do
          render :edit,
                status: :unprocessable_entity
        end

        format.turbo_stream do
          if page_form?
            render :edit, formats: [ :html ], status: :unprocessable_entity
          else
            render turbo_stream: turbo_stream.replace(
              "quick_student_form",
              partial: "students/quick_form",
              locals: {
                student: @student
              }
            ), status: :unprocessable_entity
          end
        end

      end
    end
  end

  def destroy
    @student_dom_id = helpers.dom_id(@student)

    @student.destroy

    @student_count =
        if current_user.admin?
          Student.count
        else
          current_user.students.count
        end

    respond_to do |format|
      format.html do
        redirect_to students_path,
                    notice: "Student deleted successfully."
      end

      format.turbo_stream do
        if page_form?
          redirect_to students_path, notice: "Student deleted successfully."
        else
          flash.now[:notice] = "Student deleted successfully."
        end
      end
    end
  end

  def remove_profile_photo
    @student.profile_photo.purge_later

    redirect_to @student, notice: "Profile photo deleted successfully."
  end

  def remove_document
    attachment = @student.documents.attachments.find_by(id: params[:attachment_id])

    redirect_to @student, alert: "Document not found." and return unless attachment

    attachment.purge_later

    redirect_to @student, notice: "Document deleted successfully."
  end

  def download_report
    student = current_user.student? ? Student.find_by!(email: current_user.email) : @student

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

  # True when the request originates from the full-page student form
  # (new/edit views) rather than the inline quick form on the index page.
  # Full-page submissions get standard HTML redirects; the quick form keeps
  # its in-place Turbo Stream updates.
  def page_form?
    params[:page_form].present?
  end

  def set_student
    if current_user.student? && action_name.in?(%w[generate_report download_report])
      @student = Student.find_by!(email: current_user.email)
    else
      scope = if current_user.admin?
                Student.all
      elsif current_user.teacher?
                current_user.students
      elsif current_user.student?
                Student.where(email: current_user.email)
      else
                Student.none
      end
      @student = scope.find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    if current_user.student?
      redirect_to root_path, alert: "Access denied. You can only view your own student profile." and return
    else
      raise ActiveRecord::RecordNotFound
    end
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
    params[:student][:profile_photo].present? ||
      Array(params[:student][:documents]).any?(&:present?)
  end
end
