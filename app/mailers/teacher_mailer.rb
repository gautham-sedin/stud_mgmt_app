class TeacherMailer < ApplicationMailer
  def new_student(student)
    @student = student
    @teacher = student.user

    mail(
      to: @teacher.email,
      subject: "New Student Assigned: #{@student.name}"
    )
  end

  def student_uploaded_attachments(student)
    @student = student
    @teacher = student.user

    mail(
      to: @teacher.email,
      subject: "New Attachments Uploaded by #{@student.name}"
    )
  end
end
