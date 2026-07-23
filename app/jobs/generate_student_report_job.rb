class GenerateStudentReportJob < ApplicationJob
  queue_as :default

  discard_on ActiveRecord::RecordNotFound

  def perform(student_id)
    StudentReportGenerationService.new(student_id).call
  end
end
