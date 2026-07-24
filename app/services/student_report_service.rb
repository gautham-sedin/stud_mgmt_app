class StudentReportService
  def self.queue(student)
    GenerateStudentReportJob.perform_later(student.id)
  end

  def self.queue_all
    Student.find_each do |student|
      queue(student)
    end
  end
end
