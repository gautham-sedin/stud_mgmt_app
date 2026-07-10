class StudentNotificationService
  def self.send_welcome_email(student)
    StudentMailer.welcome_email(student).deliver_later
  end

  def self.send_teacher_assignment_notification(student)
    StudentMailer.teacher_assigned_email(student).deliver_now

    TeacherMailer.new_student(student).deliver_now
  end

  def self.send_attachment_upload_notifications(student)
    StudentMailer.attachments_uploaded_email(student).deliver_now

    TeacherMailer.student_uploaded_attachments(student).deliver_now
  end

  # def self.send_marks_published_notification(student)
  #   StudentMailer.marks_published(student).deliver_now
  # end

  def self.send_report_card_ready(student)
    StudentMailer.report_card_ready(student).deliver_later
  end
end
