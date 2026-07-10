class GenerateStudentReportJob < ApplicationJob
  queue_as :default

  def perform(student_id)
    StudentReportGenerationService.new(student_id).call
  end
end