class StudentMailer < ApplicationMailer
  def welcome_email(student)
    @student = student

    mail(
      to: @student.email,
      subject: "Welcome to SedCollege!"
    )
  end

  def teacher_assigned_email(student)
    @student = student
    @teacher = student.user

    mail(
      to: @student.email,
      subject: "New Teacher Assigned: #{@teacher.name}"
    )
  end

  def attachments_uploaded_email(student)
    @student = student

    mail(
      to: @student.email,
      subject: "New Attachments Uploaded"
    )
  end

  def report_card_ready(student)
    @student = student

    mail(
      to: @student.email,
      subject: "Your Report Card is Ready"
    )
  end

  # def marks_published(student)
  #   @student = student

  #   pdf = StudentReportPdfService.new(@student).generate

  #   attachments["#{@student.name.parameterize}_report.pdf"] = pdf

  #   mail(
  #     to: @student.email,
  #     subject: "Your Marks have been Published"
  #   )
  # end
end
