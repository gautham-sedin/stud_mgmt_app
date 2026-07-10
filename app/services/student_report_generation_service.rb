require "stringio"

class StudentReportGenerationService
  def initialize(student_id)
    @student = Student.find_by(id: student_id)
  end

  def call
    return unless student

    pdf = StudentReportPdfService.new(student).generate

    attach_report(pdf)

    StudentNotificationService.send_report_card_ready(student)
  end

  private

  attr_reader :student

  def attach_report(pdf)
    student.report_card.purge_later if student.report_card.attached?

    student.report_card.attach(
      io: StringIO.new(pdf),
      filename: "#{student.name.parameterize}_report_card.pdf",
      content_type: "application/pdf"
    )
  end
end